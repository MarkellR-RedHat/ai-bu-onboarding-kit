#!/usr/bin/env bash
set -uo pipefail

# ============================================================================
#  AI BU Hub - One-Command Setup
#  Setting up your AI BU toolkit.
#
#  Usage:
#    ./setup.sh              Full install (all 17 tools)
#    ./setup.sh --minimal    Top 5 most-used tools only
#    ./setup.sh --pick       Interactive selection menu
#    ./setup.sh --dry-run    Preview without changes
#    ./setup.sh --yes        Skip prompts, accept all defaults
# ============================================================================

GITHUB_ORG="MarkellR-RedHat"
COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
MCP_CONFIG="$HOME/.claude/settings.json"
BACKUP_DIR="$HOME/.ai-bu-hub/.backups/$(date +%Y%m%d-%H%M%S)"
VERSION="2.1.0"
START_TIME=$(date +%s)

# All AI BU Hub repos with descriptions
declare -A REPO_DESC
REPO_DESC=(
  [ai-bu-claude-commands]="Core slash commands for engineering workflows"
  [ai-bu-mcp-server-kit]="MCP server configs (GitHub, Fetch, and more)"
  [ai-bu-claude-md-templates]="CLAUDE.md project templates"
  [ai-bu-daily-briefing]="Morning briefing and daily activity summaries"
  [ai-bu-meeting-notes]="Meeting notes, agendas, and action items"
  [ai-bu-status-report]="Weekly status reports from your Git history"
  [ai-bu-review-as-persona]="Get feedback from any persona you describe"
  [ai-bu-style-checker]="Red Hat writing style checker and auto-fixer"
  [ai-bu-cfp-generator]="Conference talk proposal drafts and review"
  [ai-bu-slide-outliner]="Presentation outlines and speaker notes"
  [ai-bu-prompt-library]="Reusable prompt templates"
  [ai-bu-git-productivity]="Git aliases and shortcuts"
  [ai-bu-message-polisher]="Polish emails, Slack messages, and PR descriptions"
  [ai-bu-competitive-watch]="Competitive intelligence and battlecards"
  [ai-bu-upstream-tracker]="Upstream project change monitoring"
  [ai-bu-shipped-digest]="Team shipping digest and release notes"
  [ai-bu-speed-reader]="Summarize any long document in seconds"
)

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

MINIMAL_REPOS=(
  ai-bu-claude-commands
  ai-bu-daily-briefing
  ai-bu-message-polisher
  ai-bu-status-report
  ai-bu-style-checker
)

# -------------------------------------------------------
# Terminal UI: Colors, symbols, drawing
# -------------------------------------------------------
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  MAGENTA='\033[0;35m'
  WHITE='\033[1;37m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
  CLEAR_LINE='\033[2K'
  MOVE_UP='\033[1A'
else
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' MAGENTA='' WHITE=''
  BOLD='' DIM='' NC='' CLEAR_LINE='' MOVE_UP=''
fi

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}!${NC}"
ARROW="${CYAN}>${NC}"
DOT="${DIM}.${NC}"
GEAR="${BLUE}⚙${NC}"

# Flags
DRY_RUN=false
MINIMAL=false
FULL=false
PICK=false
YES_MODE=false

# Tracking
FAILED_REPOS=()
SKIPPED_REPOS=()
INSTALLED_COMMANDS=()
TOTAL_STEPS=7
CURRENT_STEP=0
COMMANDS_INSTALLED=0
REPOS_CLONED=0
REPOS_UPDATED=0
REPOS_FAILED=0
MCP_CONFIGURED=false

# -------------------------------------------------------
# Parse flags
# -------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --minimal)  MINIMAL=true ;;
    --full)     FULL=true ;;
    --pick)     PICK=true ;;
    --yes|-y)   YES_MODE=true ;;
    --help|-h)
      cat << 'HELPEOF'
AI BU Hub Setup - One-command onboarding for the full tool suite

Usage: ./setup.sh [OPTIONS]

Options:
  --full        Install all 17 tools (default)
  --minimal     Install only the 5 most-used tools
  --pick        Interactive selection menu
  --dry-run     Preview what would be installed (no changes)
  --yes, -y     Skip interactive prompts, accept all defaults
  --help, -h    Show this help

Examples:
  ./setup.sh                    # Full interactive setup
  ./setup.sh --minimal --yes    # Quick setup, no prompts
  ./setup.sh --pick             # Choose exactly what you want
  ./setup.sh --dry-run          # See what would happen

HELPEOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (run ./setup.sh --help)"
      exit 1
      ;;
  esac
done

# -------------------------------------------------------
# Terminal width for layout
# -------------------------------------------------------
term_width() {
  local w
  w=$(tput cols 2>/dev/null || echo 80)
  [[ $w -gt 120 ]] && w=120
  echo "$w"
}

# -------------------------------------------------------
# ASCII art header
# -------------------------------------------------------
show_header() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  cat << 'ASCIIEOF'
     _    ___   ____  _   _   _   _       _
    / \  |_ _| | __ )| | | | | | | |_   _| |__
   / _ \  | |  |  _ \| | | | | |_| | | | | '_ \
  / ___ \ | |  | |_) | |_| | |  _  | |_| | |_) |
 /_/   \_\___| |____/ \___/  |_| |_|\__,_|_.__/
ASCIIEOF
  echo -e "${NC}"
  echo -e "  ${BOLD}Setting up your AI BU toolkit${NC}  ${DIM}v${VERSION}${NC}"
  echo ""

  if $DRY_RUN; then
    echo -e "  ${YELLOW}${BOLD}DRY RUN${NC} ${DIM}-- preview only, nothing will be changed${NC}"
    echo ""
  fi
}

# -------------------------------------------------------
# Progress bar
# -------------------------------------------------------
progress_bar() {
  local current=$1 total=$2 width=30
  local filled=$((current * width / total))
  local empty=$((width - filled))
  local pct=$((current * 100 / total))

  printf "  ${DIM}[${NC}"
  printf "${GREEN}"
  for ((i = 0; i < filled; i++)); do printf "█"; done
  printf "${NC}${DIM}"
  for ((i = 0; i < empty; i++)); do printf "░"; done
  printf "${NC}${DIM}]${NC} ${BOLD}%3d%%${NC}" "$pct"
}

# -------------------------------------------------------
# Step header with progress
# -------------------------------------------------------
step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo ""
  echo -e "  $(progress_bar $CURRENT_STEP $TOTAL_STEPS)"
  echo ""
  echo -e "  ${BOLD}${WHITE}$1${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
}

# -------------------------------------------------------
# Estimated time remaining
# -------------------------------------------------------
show_eta() {
  local elapsed=$(( $(date +%s) - START_TIME ))
  if [[ $CURRENT_STEP -gt 1 && $elapsed -gt 0 ]]; then
    local per_step=$((elapsed / CURRENT_STEP))
    local remaining=$(( (TOTAL_STEPS - CURRENT_STEP) * per_step ))
    if [[ $remaining -gt 60 ]]; then
      echo -e "  ${DIM}~$((remaining / 60))m $((remaining % 60))s remaining${NC}"
    elif [[ $remaining -gt 0 ]]; then
      echo -e "  ${DIM}~${remaining}s remaining${NC}"
    fi
  fi
}

# -------------------------------------------------------
# Output helpers
# -------------------------------------------------------
info()    { echo -e "  ${ARROW} $1"; }
success() { echo -e "  ${CHECK} $1"; }
warn()    { echo -e "  ${WARN} $1"; }
fail()    { echo -e "  ${CROSS} $1"; }

# -------------------------------------------------------
# Detect OS
# -------------------------------------------------------
detect_os() {
  local os="unknown"
  local pkg_mgr="unknown"

  case "$(uname -s)" in
    Darwin*)
      os="macOS $(sw_vers -productVersion 2>/dev/null || echo '')"
      if command -v brew &>/dev/null; then
        pkg_mgr="Homebrew"
      else
        pkg_mgr="none (install Homebrew: https://brew.sh)"
      fi
      ;;
    Linux*)
      if [[ -f /etc/os-release ]]; then
        os=$(. /etc/os-release && echo "$PRETTY_NAME")
      else
        os="Linux"
      fi
      if command -v dnf &>/dev/null; then
        pkg_mgr="dnf"
      elif command -v yum &>/dev/null; then
        pkg_mgr="yum"
      elif command -v apt-get &>/dev/null; then
        pkg_mgr="apt"
      elif command -v brew &>/dev/null; then
        pkg_mgr="Homebrew"
      fi
      ;;
  esac

  echo -e "  ${GEAR} OS: ${BOLD}${os}${NC}"
  echo -e "  ${GEAR} Package manager: ${BOLD}${pkg_mgr}${NC}"
  echo -e "  ${GEAR} Shell: ${BOLD}${SHELL##*/}${NC}"
}

# -------------------------------------------------------
# Install instructions per OS
# -------------------------------------------------------
install_hint() {
  local tool=$1
  case "$(uname -s)" in
    Darwin*)
      case "$tool" in
        git)   echo "brew install git" ;;
        gh)    echo "brew install gh && gh auth login" ;;
        node)  echo "brew install node" ;;
        claude) echo "npm install -g @anthropic-ai/claude-code" ;;
      esac
      ;;
    Linux*)
      case "$tool" in
        git)
          if command -v dnf &>/dev/null; then echo "sudo dnf install git"
          elif command -v apt-get &>/dev/null; then echo "sudo apt-get install git"
          else echo "Install git via your package manager"; fi
          ;;
        gh)
          echo "See https://cli.github.com/ for install instructions, then run: gh auth login"
          ;;
        node)
          echo "See https://nodejs.org/ or use: curl -fsSL https://fnm.vercel.app/install | bash"
          ;;
        claude)
          echo "npm install -g @anthropic-ai/claude-code"
          ;;
      esac
      ;;
  esac
}

# -------------------------------------------------------
# 1. Check prerequisites
# -------------------------------------------------------
check_prerequisites() {
  step "Checking prerequisites"
  show_eta
  detect_os
  echo ""

  local missing=0
  local warnings=0

  # Claude Code (required)
  if command -v claude &>/dev/null; then
    local claude_ver
    claude_ver=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    success "Claude Code ${DIM}${claude_ver}${NC}"
  else
    fail "Claude Code is not installed"
    info "Install: $(install_hint claude)"
    missing=$((missing + 1))
  fi

  # git (required)
  if command -v git &>/dev/null; then
    success "git ${DIM}$(git --version | cut -d' ' -f3)${NC}"
  else
    fail "git is not installed"
    info "Install: $(install_hint git)"
    missing=$((missing + 1))
  fi

  # gh CLI (recommended)
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
      success "GitHub CLI ${DIM}(authenticated)${NC}"
    else
      warn "GitHub CLI installed but not authenticated"
      info "Run: gh auth login"
      warnings=$((warnings + 1))
    fi
  else
    warn "GitHub CLI (gh) not installed. Some features will be limited."
    info "Install: $(install_hint gh)"
    warnings=$((warnings + 1))
  fi

  # Node.js (recommended)
  if command -v node &>/dev/null; then
    success "Node.js ${DIM}$(node --version)${NC}"
  else
    warn "Node.js not installed. MCP servers will be skipped."
    info "Install: $(install_hint node)"
    warnings=$((warnings + 1))
  fi

  # npx
  if command -v npx &>/dev/null; then
    success "npx ${DIM}available${NC}"
  else
    if command -v node &>/dev/null; then
      warn "npx not available"
      warnings=$((warnings + 1))
    fi
  fi

  echo ""
  if [[ $missing -gt 0 ]]; then
    fail "Missing ${missing} required tool(s). Fix the errors above and run setup again."
    exit 1
  fi
  if [[ $warnings -gt 0 ]]; then
    info "${YELLOW}${warnings} optional tool(s) missing.${NC} Setup will continue with reduced features."
  else
    success "${GREEN}All prerequisites met${NC}"
  fi
}

# -------------------------------------------------------
# 2. Create directories
# -------------------------------------------------------
setup_directories() {
  step "Preparing workspace"
  show_eta

  if $DRY_RUN; then
    info "Would create: $COMMANDS_DIR"
    info "Would create: $CLONE_DIR"
    return
  fi

  mkdir -p "$COMMANDS_DIR"
  success "Commands directory: ${DIM}$COMMANDS_DIR${NC}"

  mkdir -p "$CLONE_DIR"
  success "Hub directory: ${DIM}$CLONE_DIR${NC}"

  mkdir -p "$BACKUP_DIR"
  success "Backup directory: ${DIM}$BACKUP_DIR${NC}"
}

# -------------------------------------------------------
# Interactive pick mode
# -------------------------------------------------------
interactive_pick() {
  echo ""
  echo -e "  ${BOLD}Select tools to install${NC}"
  echo -e "  ${DIM}Use numbers to toggle, 'a' for all, 'n' for none, 'd' for done${NC}"
  echo ""

  local selected=()
  local toggled=()

  # Initialize all as selected
  for i in "${!ALL_REPOS[@]}"; do
    toggled[$i]=1
  done

  while true; do
    # Clear and redraw
    for i in "${!ALL_REPOS[@]}"; do
      local repo="${ALL_REPOS[$i]}"
      local num=$((i + 1))
      local marker
      if [[ ${toggled[$i]} -eq 1 ]]; then
        marker="${GREEN}[x]${NC}"
      else
        marker="${DIM}[ ]${NC}"
      fi
      printf "  ${marker} ${BOLD}%2d${NC}  %-30s ${DIM}%s${NC}\n" "$num" "$repo" "${REPO_DESC[$repo]:-}"
    done

    echo ""
    echo -ne "  ${ARROW} Toggle (1-${#ALL_REPOS[@]}), ${BOLD}a${NC}ll, ${BOLD}n${NC}one, ${BOLD}d${NC}one: "
    read -r choice

    # Move cursor up to overwrite the menu
    for ((i = 0; i <= ${#ALL_REPOS[@]} + 2; i++)); do
      echo -ne "${MOVE_UP}${CLEAR_LINE}"
    done

    case "$choice" in
      a|A)
        for i in "${!ALL_REPOS[@]}"; do toggled[$i]=1; done
        ;;
      n|N)
        for i in "${!ALL_REPOS[@]}"; do toggled[$i]=0; done
        ;;
      d|D)
        break
        ;;
      *)
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#ALL_REPOS[@]} ]]; then
          local idx=$((choice - 1))
          if [[ ${toggled[$idx]} -eq 1 ]]; then
            toggled[$idx]=0
          else
            toggled[$idx]=1
          fi
        fi
        ;;
    esac
  done

  # Build selected list
  REPOS=()
  for i in "${!ALL_REPOS[@]}"; do
    if [[ ${toggled[$i]} -eq 1 ]]; then
      REPOS+=("${ALL_REPOS[$i]}")
    fi
  done

  echo -e "  ${CHECK} Selected ${GREEN}${#REPOS[@]}${NC} tools"
}

# -------------------------------------------------------
# Select repos based on mode
# -------------------------------------------------------
select_repos() {
  if $PICK && ! $DRY_RUN; then
    interactive_pick
  elif $MINIMAL; then
    REPOS=("${MINIMAL_REPOS[@]}")
  else
    REPOS=("${ALL_REPOS[@]}")
  fi
}

# -------------------------------------------------------
# 3. Clone or update repos
# -------------------------------------------------------
sync_repos() {
  local mode_label
  if $MINIMAL; then
    mode_label="minimal (${#REPOS[@]} tools)"
  elif $PICK; then
    mode_label="custom (${#REPOS[@]} tools)"
  else
    mode_label="full (${#REPOS[@]} tools)"
  fi

  step "Installing tools / ${mode_label}"
  show_eta

  # Quick connectivity check
  if ! git ls-remote --exit-code "https://github.com/$GITHUB_ORG/ai-bu-claude-commands.git" HEAD &>/dev/null 2>&1; then
    fail "Can't reach GitHub right now. Check your internet connection and try again in a minute."
    exit 1
  fi

  if $DRY_RUN; then
    for repo in "${REPOS[@]}"; do
      local repo_dir="$CLONE_DIR/$repo"
      if [[ -d "$repo_dir/.git" ]]; then
        info "Would update: ${BOLD}$repo${NC}  ${DIM}${REPO_DESC[$repo]:-}${NC}"
      else
        info "Would install: ${BOLD}$repo${NC}  ${DIM}${REPO_DESC[$repo]:-}${NC}"
      fi
    done
    return
  fi

  local total=${#REPOS[@]}
  local current=0

  for repo in "${REPOS[@]}"; do
    current=$((current + 1))
    local repo_dir="$CLONE_DIR/$repo"
    local desc="${REPO_DESC[$repo]:-}"
    local progress="${DIM}(${current}/${total})${NC}"

    if [[ -d "$repo_dir/.git" ]]; then
      if git -C "$repo_dir" pull --quiet 2>/dev/null; then
        success "${BOLD}${repo}${NC} ${DIM}updated${NC}  ${progress}"
        REPOS_UPDATED=$((REPOS_UPDATED + 1))
      else
        warn "${repo} could not update. Using existing version.  ${progress}"
        FAILED_REPOS+=("$repo")
        REPOS_FAILED=$((REPOS_FAILED + 1))
      fi
    else
      if git clone --quiet "https://github.com/$GITHUB_ORG/$repo.git" "$repo_dir" 2>/dev/null; then
        success "${BOLD}${repo}${NC}  ${DIM}${desc}${NC}  ${progress}"
        REPOS_CLONED=$((REPOS_CLONED + 1))
      else
        warn "${repo} could not be cloned. Skipping for now.  ${progress}"
        FAILED_REPOS+=("$repo")
        REPOS_FAILED=$((REPOS_FAILED + 1))
      fi
    fi
  done

  echo ""
  if [[ $REPOS_CLONED -gt 0 ]]; then
    info "${GREEN}${REPOS_CLONED} installed${NC}"
  fi
  if [[ $REPOS_UPDATED -gt 0 ]]; then
    info "${GREEN}${REPOS_UPDATED} updated${NC}"
  fi
  if [[ $REPOS_FAILED -gt 0 ]]; then
    info "${YELLOW}${REPOS_FAILED} skipped${NC} (run setup again later to retry)"
  fi
}

# -------------------------------------------------------
# 4. Install slash commands
# -------------------------------------------------------
install_commands() {
  step "Registering slash commands"
  show_eta

  # Files to skip (not commands)
  local skip_files="README.md CONTRIBUTING.md LICENSE.md CHANGELOG.md first-steps.md commands-cheatsheet.md"

  if $DRY_RUN; then
    local would_install=0
    for repo in "${REPOS[@]}"; do
      local repo_dir="$CLONE_DIR/$repo"
      [[ ! -d "$repo_dir" ]] && continue
      for cmd_file in "$repo_dir"/commands/*.md "$repo_dir"/*.md; do
        [[ ! -f "$cmd_file" ]] && continue
        local filename
        filename=$(basename "$cmd_file")
        [[ "$skip_files" == *"$filename"* ]] && continue
        local cmd_name
        cmd_name=$(echo "$filename" | sed 's/\.md$//')
        info "Would register: /${cmd_name}"
        would_install=$((would_install + 1))
      done
    done
    echo ""
    info "Total: $would_install commands would be registered"
    return
  fi

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    [[ ! -d "$repo_dir" ]] && continue

    for cmd_file in "$repo_dir"/commands/*.md "$repo_dir"/*.md; do
      [[ ! -f "$cmd_file" ]] && continue
      local filename
      filename=$(basename "$cmd_file")
      [[ "$skip_files" == *"$filename"* ]] && continue

      # Back up existing command if it differs
      if [[ -f "$COMMANDS_DIR/$filename" ]]; then
        if ! diff -q "$cmd_file" "$COMMANDS_DIR/$filename" &>/dev/null; then
          cp "$COMMANDS_DIR/$filename" "$BACKUP_DIR/$filename" 2>/dev/null || true
        fi
      fi

      cp "$cmd_file" "$COMMANDS_DIR/$filename"
      local cmd_name
      cmd_name=$(echo "$filename" | sed 's/\.md$//')
      INSTALLED_COMMANDS+=("/$cmd_name")
      COMMANDS_INSTALLED=$((COMMANDS_INSTALLED + 1))
    done
  done

  if [[ $COMMANDS_INSTALLED -gt 0 ]]; then
    success "Registered ${GREEN}${COMMANDS_INSTALLED}${NC} slash commands into ${DIM}$COMMANDS_DIR${NC}"
  else
    warn "No commands found to install"
  fi

  # Show installed commands grouped
  if [[ ${#INSTALLED_COMMANDS[@]} -gt 0 ]]; then
    echo ""
    local per_line=4
    local count=0
    local line="    "
    for cmd in "${INSTALLED_COMMANDS[@]}"; do
      line+=$(printf "%-22s" "$cmd")
      count=$((count + 1))
      if [[ $((count % per_line)) -eq 0 ]]; then
        echo -e "  ${DIM}${line}${NC}"
        line="    "
      fi
    done
    if [[ $((count % per_line)) -ne 0 ]]; then
      echo -e "  ${DIM}${line}${NC}"
    fi
  fi
}

# -------------------------------------------------------
# 5. Configure MCP servers
# -------------------------------------------------------
setup_mcp_servers() {
  step "Configuring MCP servers"
  show_eta

  if ! command -v node &>/dev/null; then
    warn "Node.js not available. Skipping MCP server setup."
    info "Install Node.js and run setup again to enable MCP servers."
    return
  fi

  if $DRY_RUN; then
    info "Would configure: Fetch MCP server"
    if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
      info "Would configure: GitHub MCP server"
    fi
    return
  fi

  local mcp_choice="n"
  if $YES_MODE; then
    mcp_choice="y"
  else
    echo ""
    read -rp "$(echo -e "  ${ARROW} Configure MCP servers (GitHub, Fetch)? [Y/n] ")" mcp_choice
    mcp_choice="${mcp_choice:-y}"
  fi

  if [[ "${mcp_choice,,}" == "n" ]]; then
    info "Skipping MCP server setup"
    return
  fi

  local existing_settings="{}"
  if [[ -f "$MCP_CONFIG" ]]; then
    existing_settings=$(cat "$MCP_CONFIG")
    # Back up existing settings
    cp "$MCP_CONFIG" "$BACKUP_DIR/settings.json.bak" 2>/dev/null || true
  fi

  local gh_ready=false
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    gh_ready=true
  fi

  local tmp_config
  tmp_config=$(mktemp)

  node -e "
    const fs = require('fs');
    let config = {};
    try { config = JSON.parse(process.argv[1]); } catch(e) {}
    if (!config.mcpServers) config.mcpServers = {};

    if (${gh_ready}) {
      config.mcpServers['github'] = {
        command: 'npx',
        args: ['-y', '@modelcontextprotocol/server-github'],
        env: {}
      };
    }

    config.mcpServers['fetch'] = {
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-fetch']
    };

    fs.writeFileSync('${tmp_config}', JSON.stringify(config, null, 2));
  " "$existing_settings" 2>/dev/null

  if [[ -f "$tmp_config" ]] && [[ -s "$tmp_config" ]]; then
    mkdir -p "$(dirname "$MCP_CONFIG")"
    cp "$tmp_config" "$MCP_CONFIG"
    success "Fetch MCP server configured"
    if $gh_ready; then
      success "GitHub MCP server configured ${DIM}(authenticated via gh CLI)${NC}"
    fi
    MCP_CONFIGURED=true
  else
    warn "Could not configure MCP servers automatically."
    info "See ai-bu-mcp-server-kit repo for manual setup."
  fi
  rm -f "$tmp_config"
}

# -------------------------------------------------------
# 6. Git productivity aliases
# -------------------------------------------------------
setup_git_aliases() {
  step "Git productivity aliases"
  show_eta

  if $DRY_RUN; then
    info "Would install git aliases: co, br, st, lg, last, unstage, amend"
    return
  fi

  local alias_choice="n"
  if $YES_MODE; then
    alias_choice="y"
  else
    echo ""
    read -rp "$(echo -e "  ${ARROW} Install git productivity aliases? [Y/n] ")" alias_choice
    alias_choice="${alias_choice:-y}"
  fi

  if [[ "${alias_choice,,}" == "n" ]]; then
    info "Skipping git aliases"
    return
  fi

  local alias_source="$CLONE_DIR/ai-bu-git-productivity"
  if [[ -d "$alias_source" ]] && [[ -f "$alias_source/aliases.sh" ]]; then
    source "$alias_source/aliases.sh"
    success "Git aliases installed from ai-bu-git-productivity"
  else
    git config --global alias.co checkout 2>/dev/null || true
    git config --global alias.br branch 2>/dev/null || true
    git config --global alias.st status 2>/dev/null || true
    git config --global alias.lg "log --oneline --graph --decorate -20" 2>/dev/null || true
    git config --global alias.last "log -1 --stat" 2>/dev/null || true
    git config --global alias.unstage "reset HEAD --" 2>/dev/null || true
    git config --global alias.amend "commit --amend --no-edit" 2>/dev/null || true
    success "Git aliases installed: ${DIM}co, br, st, lg, last, unstage, amend${NC}"
  fi
}

# -------------------------------------------------------
# 7. Summary dashboard
# -------------------------------------------------------
print_summary() {
  local elapsed=$(( $(date +%s) - START_TIME ))
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))

  echo ""
  echo ""

  if $DRY_RUN; then
    echo -e "  ${YELLOW}${BOLD}DRY RUN COMPLETE${NC}"
    echo -e "  ${DIM}No changes were made. Run without --dry-run to install.${NC}"
    echo ""
    return
  fi

  # Celebration header
  echo -e "  ${GREEN}${BOLD}=====================================================${NC}"
  echo -e "  ${GREEN}${BOLD}  SETUP COMPLETE${NC}"
  echo -e "  ${GREEN}${BOLD}=====================================================${NC}"
  echo ""
  echo -e "  ${BOLD}You now have ${GREEN}${COMMANDS_INSTALLED}${NC}${BOLD} slash commands available in Claude Code.${NC}"
  echo ""

  # Stats
  echo -e "  ${BOLD}What was installed${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
  printf "  %-30s ${GREEN}${BOLD}%s${NC}\n" "Slash commands" "$COMMANDS_INSTALLED"
  printf "  %-30s ${GREEN}${BOLD}%s${NC}\n" "Tool repos" "$((REPOS_CLONED + REPOS_UPDATED))"
  if $MCP_CONFIGURED; then
    printf "  %-30s ${GREEN}${BOLD}%s${NC}\n" "MCP servers" "configured"
  fi
  printf "  %-30s ${DIM}%s${NC}\n" "Setup time" "${minutes}m ${seconds}s"
  echo ""

  # File locations
  echo -e "  ${BOLD}Where things live${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
  echo -e "  Commands      ${DIM}$COMMANDS_DIR${NC}"
  echo -e "  Hub repos     ${DIM}$CLONE_DIR${NC}"
  echo -e "  MCP config    ${DIM}$MCP_CONFIG${NC}"
  echo -e "  Backups       ${DIM}$BACKUP_DIR${NC}"

  # Failures (friendly, non-scary)
  if [[ ${#FAILED_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${YELLOW}${BOLD}Skipped (not blocking)${NC}"
    echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
    for f in "${FAILED_REPOS[@]}"; do
      echo -e "  ${WARN} $f"
    done
    echo -e "  ${DIM}Run setup.sh again when you have a stable connection to retry.${NC}"
  fi

  if $MINIMAL; then
    echo ""
    echo -e "  ${DIM}Minimal install: only the top 5 tools.${NC}"
    echo -e "  ${DIM}Run setup.sh --full or setup.sh --pick for more.${NC}"
  fi

  # The big moment: try this first
  echo ""
  echo -e "  ${BOLD}${GREEN}Try this first:${NC}"
  echo ""
  echo -e "    ${CYAN}claude /read-the-room${NC}"
  echo -e "    ${DIM}Paste any Slack message or email and Claude decodes${NC}"
  echo -e "    ${DIM}what is really being said underneath the surface.${NC}"
  echo ""
  echo -e "  ${BOLD}Then explore:${NC}"
  echo ""
  echo -e "  ${CYAN}1${NC}  claude /briefing        ${DIM}Your daily GitHub activity summary${NC}"
  echo -e "  ${CYAN}2${NC}  claude /polish          ${DIM}Clean up a rough email or message${NC}"
  echo -e "  ${CYAN}3${NC}  claude /status-report   ${DIM}Generate a weekly status report from Git${NC}"
  echo -e "  ${CYAN}4${NC}  claude /style-check     ${DIM}Check writing against Red Hat style${NC}"
  echo ""
  echo -e "  ${DIM}Guided walkthrough:  first-steps.md${NC}"
  echo -e "  ${DIM}Full command list:   commands-cheatsheet.md${NC}"
  echo ""
  echo -e "  ${BOLD}Management${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"
  echo -e "  Update all tools     ${CYAN}./update.sh${NC}"
  echo -e "  Verify installation  ${CYAN}./verify.sh${NC}"
  echo -e "  Uninstall            ${CYAN}./uninstall.sh${NC}"
  echo ""
}

# -------------------------------------------------------
# Main
# -------------------------------------------------------
main() {
  show_header
  select_repos
  check_prerequisites
  setup_directories
  sync_repos
  install_commands
  setup_mcp_servers
  setup_git_aliases
  print_summary
}

main
