#!/usr/bin/env bash
set -euo pipefail

# AI BU Hub Onboarding Kit - Verify Script
# Checks that everything is installed correctly and working.
# Outputs a clean pass/fail report with a summary score.

COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
MCP_CONFIG="$HOME/.claude/settings.json"

REPOS=(
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

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
DASH="${YELLOW}-${NC}"

total=0
passed=0
failed=0
skipped=0

pass() {
  total=$((total + 1))
  passed=$((passed + 1))
  echo -e "  ${CHECK}  $1"
}

fail() {
  total=$((total + 1))
  failed=$((failed + 1))
  echo -e "  ${CROSS}  $1"
}

skip() {
  total=$((total + 1))
  skipped=$((skipped + 1))
  echo -e "  ${DASH}  $1 ${DIM}(optional)${NC}"
}

section() {
  echo ""
  echo -e "  ${BOLD}$1${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' {1..46})${NC}"
}

main() {
  echo ""
  echo -e "${BOLD}AI BU Hub - Installation Verification${NC}"

  # ---- Prerequisites ----
  section "Prerequisites"

  if command -v claude &>/dev/null; then
    pass "Claude Code is installed"
  else
    fail "Claude Code is not installed"
  fi

  if command -v git &>/dev/null; then
    pass "git is installed"
  else
    fail "git is not installed"
  fi

  if command -v gh &>/dev/null; then
    pass "GitHub CLI (gh) is installed"
  else
    fail "GitHub CLI (gh) is not installed"
  fi

  if command -v node &>/dev/null; then
    pass "Node.js is installed ($(node --version))"
  else
    fail "Node.js is not installed"
  fi

  if command -v npx &>/dev/null; then
    pass "npx is available"
  else
    fail "npx is not available"
  fi

  # ---- Directories ----
  section "Directories"

  if [[ -d "$COMMANDS_DIR" ]]; then
    local cmd_count
    cmd_count=$(find "$COMMANDS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    pass "Commands directory exists ($cmd_count commands found)"
  else
    fail "Commands directory not found: $COMMANDS_DIR"
  fi

  if [[ -d "$CLONE_DIR" ]]; then
    pass "Hub repos directory exists: $CLONE_DIR"
  else
    fail "Hub repos directory not found: $CLONE_DIR"
  fi

  # ---- Repos ----
  section "Hub Repos"

  local repos_ok=0
  local repos_missing=0
  for repo in "${REPOS[@]}"; do
    if [[ -d "$CLONE_DIR/$repo/.git" ]]; then
      pass "$repo"
      repos_ok=$((repos_ok + 1))
    else
      fail "$repo (not cloned)"
      repos_missing=$((repos_missing + 1))
    fi
  done

  # ---- MCP ----
  section "MCP Servers"

  if [[ -f "$MCP_CONFIG" ]]; then
    if command -v node &>/dev/null; then
      if node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); process.exit(c.mcpServers && c.mcpServers.github ? 0 : 1)" 2>/dev/null; then
        pass "GitHub MCP server configured"
      else
        skip "GitHub MCP server not configured"
      fi

      if node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); process.exit(c.mcpServers && c.mcpServers.fetch ? 0 : 1)" 2>/dev/null; then
        pass "Fetch MCP server configured"
      else
        skip "Fetch MCP server not configured"
      fi
    else
      skip "Cannot check MCP config without Node.js"
    fi
  else
    skip "No MCP configuration file found"
  fi

  # ---- Authentication ----
  section "Authentication"

  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    pass "GitHub CLI is authenticated"
  else
    fail "GitHub CLI is not authenticated (run: gh auth login)"
  fi

  # ---- Score ----
  echo ""
  echo -e "  ${DIM}$(printf '%.0s=' {1..50})${NC}"

  local score_color="${GREEN}"
  if [[ $failed -gt 0 ]]; then
    score_color="${RED}"
  fi

  local counted=$((passed + failed))
  echo -e "  ${BOLD}Score: ${score_color}${passed}/${counted} checks passed${NC}"

  if [[ $skipped -gt 0 ]]; then
    echo -e "  ${DIM}($skipped optional checks skipped)${NC}"
  fi

  echo ""

  if [[ $failed -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}All checks passed.${NC} You are ready to go."
  elif [[ $failed -le 3 ]]; then
    echo -e "  ${YELLOW}${BOLD}Most checks passed.${NC} Review the failures above, then run setup.sh to fix."
  else
    echo -e "  ${RED}${BOLD}Multiple failures detected.${NC} Run setup.sh to install missing components."
  fi

  echo ""
  exit $failed
}

main "$@"
