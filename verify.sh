#!/usr/bin/env bash
set -uo pipefail

# ============================================================================
#  AI BU Hub - Health Check Dashboard
#  Full diagnostic scan of your AI BU Hub installation.
#
#  Usage:
#    ./verify.sh           Full health check with dashboard
#    ./verify.sh --quiet   Summary only (exit code = number of failures)
# ============================================================================

COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
MCP_CONFIG="$HOME/.claude/settings.json"

ALL_REPOS=(
  ai-bu-claude-commands
  ai-bu-mcp-server-kit
  ai-bu-claude-md-templates
  ai-bu-daily-briefing
  ai-bu-meeting-notes
  ai-bu-status-report
  ai-bu-review-as-persona
  ai-bu-style-checker
  ai-bu-cfp-generator
  ai-bu-slide-outliner
  ai-bu-prompt-library
  ai-bu-git-productivity
  ai-bu-message-polisher
  ai-bu-competitive-watch
  ai-bu-upstream-tracker
  ai-bu-shipped-digest
  ai-bu-speed-reader
)

# -------------------------------------------------------
# Colors and symbols
# -------------------------------------------------------
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  WHITE='\033[1;37m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' WHITE=''
  BOLD='' DIM='' NC=''
fi

PASS="${GREEN}PASS${NC}"
FAIL="${RED}FAIL${NC}"
WARN="${YELLOW}WARN${NC}"
SKIP="${DIM}SKIP${NC}"

QUIET=false
for arg in "$@"; do
  case "$arg" in
    --quiet|-q) QUIET=true ;;
  esac
done

# Counters
total=0
passed=0
failed=0
warned=0
skipped=0

# Problem tracking for diagnostics
PROBLEMS=()
FIXES=()

# -------------------------------------------------------
# Test helpers
# -------------------------------------------------------
pass() {
  total=$((total + 1))
  passed=$((passed + 1))
  if ! $QUIET; then
    printf "  ${PASS}  %-45s %s\n" "$1" "${2:-}"
  fi
}

fail() {
  total=$((total + 1))
  failed=$((failed + 1))
  if ! $QUIET; then
    printf "  ${FAIL}  %-45s %s\n" "$1" "${2:-}"
  fi
  PROBLEMS+=("$1")
  if [[ -n "${3:-}" ]]; then
    FIXES+=("$3")
  else
    FIXES+=("")
  fi
}

warn_check() {
  total=$((total + 1))
  warned=$((warned + 1))
  if ! $QUIET; then
    printf "  ${WARN}  %-45s %s\n" "$1" "${2:-}"
  fi
}

skip_check() {
  total=$((total + 1))
  skipped=$((skipped + 1))
  if ! $QUIET; then
    printf "  ${SKIP}  %-45s %s\n" "$1" "${DIM}${2:-optional}${NC}"
  fi
}

section() {
  if ! $QUIET; then
    echo ""
    printf "  ${BOLD}${WHITE}%-50s${NC}\n" "$1"
    echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
  fi
}

# -------------------------------------------------------
# Header
# -------------------------------------------------------
show_header() {
  if $QUIET; then return; fi
  echo ""
  echo -e "  ${CYAN}${BOLD}AI BU Hub -- Health Check Dashboard${NC}"
  echo -e "  ${DIM}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
}

# -------------------------------------------------------
# Prerequisites
# -------------------------------------------------------
check_prerequisites() {
  section "Prerequisites"

  # Claude Code
  if command -v claude &>/dev/null; then
    local ver
    ver=$(claude --version 2>/dev/null | head -1 || echo "?")
    pass "Claude Code" "${DIM}${ver}${NC}"
  else
    fail "Claude Code" "not found" "Install: npm install -g @anthropic-ai/claude-code"
  fi

  # git
  if command -v git &>/dev/null; then
    pass "git" "${DIM}$(git --version | cut -d' ' -f3)${NC}"
  else
    fail "git" "not found" "Install git via your package manager"
  fi

  # gh CLI
  if command -v gh &>/dev/null; then
    pass "GitHub CLI (gh)" "${DIM}$(gh --version 2>/dev/null | head -1 | cut -d' ' -f3)${NC}"
  else
    fail "GitHub CLI (gh)" "not found" "Install: brew install gh (macOS) or see https://cli.github.com/"
  fi

  # Node.js
  if command -v node &>/dev/null; then
    pass "Node.js" "${DIM}$(node --version)${NC}"
  else
    warn_check "Node.js" "${DIM}needed for MCP servers${NC}"
  fi

  # npx
  if command -v npx &>/dev/null; then
    pass "npx" "${DIM}available${NC}"
  elif command -v node &>/dev/null; then
    warn_check "npx" "${DIM}needed for MCP servers${NC}"
  else
    skip_check "npx" "requires Node.js"
  fi
}

# -------------------------------------------------------
# Authentication
# -------------------------------------------------------
check_auth() {
  section "Authentication"

  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
      local gh_user
      gh_user=$(gh api user --jq '.login' 2>/dev/null || echo "authenticated")
      pass "GitHub CLI authenticated" "${DIM}${gh_user}${NC}"
    else
      fail "GitHub CLI authenticated" "not logged in" "Run: gh auth login"
    fi
  else
    skip_check "GitHub CLI authentication" "gh not installed"
  fi
}

# -------------------------------------------------------
# Directories
# -------------------------------------------------------
check_directories() {
  section "Directories"

  if [[ -d "$COMMANDS_DIR" ]]; then
    local cmd_count
    cmd_count=$(find "$COMMANDS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    pass "Commands directory" "${DIM}${cmd_count} commands${NC}"
  else
    fail "Commands directory" "missing: $COMMANDS_DIR" "Run: ./setup.sh"
  fi

  if [[ -d "$CLONE_DIR" ]]; then
    local repo_count
    repo_count=$(find "$CLONE_DIR" -maxdepth 1 -type d -name "ai-bu-*" 2>/dev/null | wc -l | tr -d ' ')
    pass "Hub repos directory" "${DIM}${repo_count} repos${NC}"
  else
    fail "Hub repos directory" "missing: $CLONE_DIR" "Run: ./setup.sh"
  fi
}

# -------------------------------------------------------
# Repos
# -------------------------------------------------------
check_repos() {
  section "Hub Repos (${#ALL_REPOS[@]} expected)"

  local repos_ok=0
  local repos_missing=0
  local repos_dirty=0

  for repo in "${ALL_REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    if [[ -d "$repo_dir/.git" ]]; then
      # Check if repo is behind remote
      local status_info=""
      local behind
      behind=$(git -C "$repo_dir" rev-list HEAD..origin/main --count 2>/dev/null || echo "0")
      if [[ "$behind" -gt 0 ]]; then
        status_info="${YELLOW}${behind} commits behind${NC}"
        repos_dirty=$((repos_dirty + 1))
      fi

      # Count command files
      local cmd_count=0
      for f in "$repo_dir"/commands/*.md; do
        [[ -f "$f" ]] && cmd_count=$((cmd_count + 1))
      done

      if [[ $cmd_count -gt 0 ]]; then
        pass "$repo" "${DIM}${cmd_count} commands${NC} ${status_info}"
      else
        pass "$repo" "${DIM}cloned${NC} ${status_info}"
      fi
      repos_ok=$((repos_ok + 1))
    else
      fail "$repo" "not cloned" "Run: ./setup.sh"
      repos_missing=$((repos_missing + 1))
    fi
  done

  if ! $QUIET; then
    echo ""
    printf "  ${DIM}%-20s${NC} ${GREEN}%d${NC} cloned" "Repos:" "$repos_ok"
    if [[ $repos_missing -gt 0 ]]; then
      printf ", ${RED}%d${NC} missing" "$repos_missing"
    fi
    if [[ $repos_dirty -gt 0 ]]; then
      printf ", ${YELLOW}%d${NC} behind" "$repos_dirty"
    fi
    echo ""
  fi
}

# -------------------------------------------------------
# Slash commands
# -------------------------------------------------------
check_commands() {
  section "Slash Commands"

  if [[ ! -d "$COMMANDS_DIR" ]]; then
    fail "Commands directory exists" "missing" "Run: ./setup.sh"
    return
  fi

  # Check a sample of key commands that should be present
  local key_commands=(
    "briefing:Daily briefing"
    "polish:Message polisher"
    "style-check:Style checker"
    "status-report:Status reports"
    "meeting-notes:Meeting notes"
    "review-as:Persona review"
    "slides:Slide outliner"
    "cfp:CFP generator"
    "shipped:Shipped digest"
    "speedread:Speed reader"
    "upstream:Upstream tracker"
    "read-the-room:Room reader"
  )

  for entry in "${key_commands[@]}"; do
    local cmd="${entry%%:*}"
    local desc="${entry##*:}"
    if [[ -f "$COMMANDS_DIR/${cmd}.md" ]]; then
      pass "/${cmd}" "${DIM}${desc}${NC}"
    else
      fail "/${cmd}" "not installed" "Run: ./setup.sh"
    fi
  done

  # Count total installed
  local total_installed
  total_installed=$(find "$COMMANDS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if ! $QUIET; then
    echo ""
    echo -e "  ${DIM}Total installed: ${total_installed} slash commands${NC}"
  fi
}

# -------------------------------------------------------
# MCP servers
# -------------------------------------------------------
check_mcp() {
  section "MCP Servers"

  if [[ ! -f "$MCP_CONFIG" ]]; then
    skip_check "MCP configuration file" "not configured"
    return
  fi

  if ! command -v node &>/dev/null; then
    skip_check "MCP server check" "requires Node.js"
    return
  fi

  # Check GitHub MCP
  if node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); process.exit(c.mcpServers && c.mcpServers.github ? 0 : 1)" 2>/dev/null; then
    pass "GitHub MCP server" "${DIM}configured${NC}"

    # Try to validate it works
    if command -v npx &>/dev/null; then
      if timeout 10 npx -y @modelcontextprotocol/server-github --help &>/dev/null 2>&1; then
        pass "GitHub MCP server reachable" "${DIM}responding${NC}"
      else
        warn_check "GitHub MCP server reachable" "${DIM}could not verify${NC}"
      fi
    fi
  else
    skip_check "GitHub MCP server" "not configured"
  fi

  # Check Fetch MCP
  if node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); process.exit(c.mcpServers && c.mcpServers.fetch ? 0 : 1)" 2>/dev/null; then
    pass "Fetch MCP server" "${DIM}configured${NC}"
  else
    skip_check "Fetch MCP server" "not configured"
  fi

  # Check for any other MCP servers
  local mcp_count
  mcp_count=$(node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); console.log(Object.keys(c.mcpServers||{}).length)" 2>/dev/null || echo "0")
  if [[ "$mcp_count" -gt 0 ]]; then
    if ! $QUIET; then
      echo -e "  ${DIM}Total MCP servers: ${mcp_count}${NC}"
    fi
  fi
}

# -------------------------------------------------------
# Health score and diagnostics
# -------------------------------------------------------
show_dashboard() {
  if $QUIET; then
    echo "${passed}/${total} passed (${failed} failed, ${warned} warnings, ${skipped} skipped)"
    exit $failed
  fi

  echo ""
  echo -e "  ${BOLD}${WHITE}=====================================================${NC}"
  echo -e "  ${BOLD}${WHITE}  Health Check Results${NC}"
  echo -e "  ${BOLD}${WHITE}=====================================================${NC}"
  echo ""

  # Calculate health score
  local checkable=$((total - skipped))
  local health_pct=0
  if [[ $checkable -gt 0 ]]; then
    health_pct=$(( (passed * 100) / checkable ))
  fi

  # Score color
  local score_color="${GREEN}"
  local status_text="ALL SYSTEMS GO"
  local status_icon="[OK]"
  if [[ $health_pct -lt 100 && $health_pct -ge 80 ]]; then
    score_color="${YELLOW}"
    status_text="MOSTLY HEALTHY"
    status_icon="[!!]"
  elif [[ $health_pct -lt 80 && $health_pct -ge 50 ]]; then
    score_color="${YELLOW}"
    status_text="NEEDS ATTENTION"
    status_icon="[!!]"
  elif [[ $health_pct -lt 50 ]]; then
    score_color="${RED}"
    status_text="SETUP INCOMPLETE"
    status_icon="[XX]"
  fi

  # Health bar
  local bar_width=30
  local filled=$((health_pct * bar_width / 100))
  local empty=$((bar_width - filled))

  printf "  Health: "
  printf "${score_color}"
  for ((i = 0; i < filled; i++)); do printf "█"; done
  printf "${NC}${DIM}"
  for ((i = 0; i < empty; i++)); do printf "░"; done
  printf "${NC}"
  printf "  ${score_color}${BOLD}%d%%${NC}" "$health_pct"
  echo ""
  echo ""
  echo -e "  ${score_color}${BOLD}${status_icon} ${status_text}${NC}"
  echo ""

  # Stats
  printf "  ${GREEN}%-12s${NC} %d\n" "Passed:" "$passed"
  printf "  ${RED}%-12s${NC} %d\n" "Failed:" "$failed"
  printf "  ${YELLOW}%-12s${NC} %d\n" "Warnings:" "$warned"
  printf "  ${DIM}%-12s${NC} %d\n" "Skipped:" "$skipped"
  echo ""

  # Diagnostics for failures
  if [[ ${#PROBLEMS[@]} -gt 0 ]]; then
    echo -e "  ${BOLD}${WHITE}Diagnostics${NC}"
    echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
    for i in "${!PROBLEMS[@]}"; do
      echo -e "  ${RED}x${NC} ${PROBLEMS[$i]}"
      if [[ -n "${FIXES[$i]}" ]]; then
        echo -e "    ${CYAN}Fix:${NC} ${FIXES[$i]}"
      fi
    done
    echo ""
    echo -e "  ${DIM}Quick fix: run ./setup.sh to install missing components${NC}"
  fi

  echo ""
  exit $failed
}

# -------------------------------------------------------
# Main
# -------------------------------------------------------
main() {
  show_header
  check_prerequisites
  check_auth
  check_directories
  check_repos
  check_commands
  check_mcp
  show_dashboard
}

main
