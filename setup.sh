#!/usr/bin/env bash
set -euo pipefail

# AI BU Hub Onboarding Kit - Setup Script
# One command to configure Claude Code with all AI BU Hub tools.
# Safe to run multiple times (idempotent).

GITHUB_ORG="MarkellR-RedHat"
COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
MCP_CONFIG="$HOME/.claude/settings.json"

# All AI BU Hub repos
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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -------------------------------------------------------
# 1. Check prerequisites
# -------------------------------------------------------
check_prerequisites() {
  info "Checking prerequisites..."
  local missing=0

  if command -v claude &>/dev/null; then
    success "Claude Code is installed"
  else
    error "Claude Code is not installed. See https://docs.anthropic.com/en/docs/claude-code"
    missing=1
  fi

  if command -v gh &>/dev/null; then
    success "GitHub CLI (gh) is installed"
  else
    warn "GitHub CLI (gh) is not installed. MCP GitHub server setup will be skipped."
    warn "Install it: https://cli.github.com/"
  fi

  if command -v git &>/dev/null; then
    success "git is installed"
  else
    error "git is not installed. Install git and try again."
    missing=1
  fi

  if command -v node &>/dev/null; then
    success "Node.js is installed ($(node --version))"
  else
    warn "Node.js is not installed. Some MCP servers may not work."
    warn "Install it: https://nodejs.org/"
  fi

  if command -v npx &>/dev/null; then
    success "npx is available"
  else
    warn "npx is not available. Some MCP servers may not work."
  fi

  if [[ $missing -eq 1 ]]; then
    error "Missing required tools. Fix the errors above and run setup again."
    exit 1
  fi

  echo ""
}

# -------------------------------------------------------
# 2. Create directories
# -------------------------------------------------------
setup_directories() {
  info "Setting up directories..."

  mkdir -p "$COMMANDS_DIR"
  success "Commands directory ready: $COMMANDS_DIR"

  mkdir -p "$CLONE_DIR"
  success "Hub directory ready: $CLONE_DIR"

  echo ""
}

# -------------------------------------------------------
# 3. Clone or update all Hub repos
# -------------------------------------------------------
sync_repos() {
  info "Syncing AI BU Hub repos..."
  local cloned=0
  local updated=0
  local failed=0

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    if [[ -d "$repo_dir/.git" ]]; then
      if git -C "$repo_dir" pull --quiet 2>/dev/null; then
        updated=$((updated + 1))
      else
        warn "Failed to update $repo (may be offline). Using existing version."
        failed=$((failed + 1))
      fi
    else
      if git clone --quiet "https://github.com/$GITHUB_ORG/$repo.git" "$repo_dir" 2>/dev/null; then
        cloned=$((cloned + 1))
      else
        warn "Could not clone $repo. It may not exist yet or you may be offline."
        failed=$((failed + 1))
      fi
    fi
  done

  success "Repos synced: $cloned cloned, $updated updated, $failed skipped"
  echo ""
}

# -------------------------------------------------------
# 4. Install slash commands
# -------------------------------------------------------
install_commands() {
  info "Installing slash commands..."
  local installed=0

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    if [[ ! -d "$repo_dir" ]]; then
      continue
    fi

    # Look for .md command files in common locations
    for cmd_file in "$repo_dir"/commands/*.md "$repo_dir"/*.md; do
      if [[ -f "$cmd_file" ]]; then
        local filename
        filename=$(basename "$cmd_file")
        # Skip README and other non-command files
        if [[ "$filename" == "README.md" ]] || [[ "$filename" == "CONTRIBUTING.md" ]] || \
           [[ "$filename" == "LICENSE.md" ]] || [[ "$filename" == "CHANGELOG.md" ]] || \
           [[ "$filename" == "first-steps.md" ]]; then
          continue
        fi
        cp "$cmd_file" "$COMMANDS_DIR/$filename"
        installed=$((installed + 1))
      fi
    done
  done

  success "Installed $installed slash commands to $COMMANDS_DIR"
  echo ""
}

# -------------------------------------------------------
# 5. Optionally set up MCP servers
# -------------------------------------------------------
setup_mcp_servers() {
  echo ""
  read -rp "$(echo -e "${BLUE}Set up MCP servers (GitHub, Fetch)?${NC} [y/N] ")" mcp_choice
  if [[ "${mcp_choice,,}" != "y" ]]; then
    info "Skipping MCP server setup. You can configure them later."
    return
  fi

  info "Configuring MCP servers..."

  # Check if settings.json exists and has content
  local existing_settings="{}"
  if [[ -f "$MCP_CONFIG" ]]; then
    existing_settings=$(cat "$MCP_CONFIG")
  fi

  # Check if gh is authenticated
  local gh_ready=false
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    gh_ready=true
  fi

  # Build MCP config using a temp file
  local tmp_config
  tmp_config=$(mktemp)

  if command -v node &>/dev/null; then
    # Use node to merge JSON safely
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
      success "MCP servers configured in $MCP_CONFIG"
      if $gh_ready; then
        success "  - GitHub MCP server (authenticated via gh CLI)"
      fi
      success "  - Fetch MCP server"
    else
      warn "Could not configure MCP servers automatically."
      warn "See the ai-bu-mcp-server-kit repo for manual setup instructions."
    fi
    rm -f "$tmp_config"
  else
    warn "Node.js not available. Skipping MCP setup."
    warn "Install Node.js and run setup again, or configure MCP servers manually."
  fi

  echo ""
}

# -------------------------------------------------------
# 6. Optionally install git productivity aliases
# -------------------------------------------------------
setup_git_aliases() {
  echo ""
  read -rp "$(echo -e "${BLUE}Install git productivity aliases?${NC} [y/N] ")" alias_choice
  if [[ "${alias_choice,,}" != "y" ]]; then
    info "Skipping git aliases."
    return
  fi

  info "Installing git aliases..."

  local alias_source="$CLONE_DIR/ai-bu-git-productivity"
  if [[ -d "$alias_source" ]] && [[ -f "$alias_source/aliases.sh" ]]; then
    source "$alias_source/aliases.sh"
    success "Git aliases installed from ai-bu-git-productivity"
  else
    # Install some sensible defaults
    git config --global alias.co checkout 2>/dev/null || true
    git config --global alias.br branch 2>/dev/null || true
    git config --global alias.st status 2>/dev/null || true
    git config --global alias.lg "log --oneline --graph --decorate -20" 2>/dev/null || true
    git config --global alias.last "log -1 --stat" 2>/dev/null || true
    git config --global alias.unstage "reset HEAD --" 2>/dev/null || true
    git config --global alias.amend "commit --amend --no-edit" 2>/dev/null || true
    success "Default git aliases installed"
  fi

  echo ""
}

# -------------------------------------------------------
# 7. Print summary
# -------------------------------------------------------
print_summary() {
  echo ""
  echo -e "${GREEN}============================================${NC}"
  echo -e "${GREEN}  AI BU Hub Setup Complete${NC}"
  echo -e "${GREEN}============================================${NC}"
  echo ""

  # Count installed commands
  local cmd_count=0
  if [[ -d "$COMMANDS_DIR" ]]; then
    cmd_count=$(find "$COMMANDS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  fi

  echo -e "  Slash commands installed:  ${GREEN}${cmd_count}${NC}"
  echo -e "  Commands directory:        $COMMANDS_DIR"
  echo -e "  Hub repos directory:       $CLONE_DIR"
  echo ""
  echo -e "${YELLOW}Try these first:${NC}"
  echo ""
  echo "  1. claude /briefing      - Get your daily GitHub activity summary"
  echo "  2. claude /polish        - Clean up a rough email or message draft"
  echo "  3. claude /style-check   - Check a blog post against Red Hat style"
  echo "  4. claude /status-report - Generate a weekly status report"
  echo ""
  echo "  Run 'claude' in any project directory and use /help to see"
  echo "  all available slash commands."
  echo ""
  echo -e "  To update commands later:  ${BLUE}./update.sh${NC}"
  echo -e "  To verify installation:    ${BLUE}./verify.sh${NC}"
  echo -e "  To uninstall everything:   ${BLUE}./uninstall.sh${NC}"
  echo ""
  echo "  For a guided walkthrough, see first-steps.md"
  echo ""
}

# -------------------------------------------------------
# Main
# -------------------------------------------------------
main() {
  echo ""
  echo -e "${GREEN}AI BU Hub Onboarding Kit${NC}"
  echo -e "Setting up Claude Code with AI BU Hub tools"
  echo ""

  check_prerequisites
  setup_directories
  sync_repos
  install_commands
  setup_mcp_servers
  setup_git_aliases
  print_summary
}

main "$@"
