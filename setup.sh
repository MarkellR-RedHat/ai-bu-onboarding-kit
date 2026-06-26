#!/usr/bin/env bash
set -uo pipefail

# AI BU Hub Onboarding Kit - Setup Script
# One command to configure Claude Code with all AI BU Hub tools.
# Safe to run multiple times (idempotent).
#
# Flags:
#   --minimal   Only install the 5 most-used commands
#   --dry-run   Show what would be installed without doing it
#   --yes       Skip interactive prompts (answer yes to all)

GITHUB_ORG="MarkellR-RedHat"
COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
MCP_CONFIG="$HOME/.claude/settings.json"

# All AI BU Hub repos
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

# The 5 most-used repos for --minimal installs
MINIMAL_REPOS=(
  ai-bu-claude-commands
  ai-bu-daily-briefing
  ai-bu-message-polisher
  ai-bu-status-report
  ai-bu-style-checker
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Symbols
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}!${NC}"
ARROW="${BLUE}→${NC}"

# Flags
DRY_RUN=false
MINIMAL=false
YES_MODE=false

# Track failures for end-of-run report
FAILED_REPOS=()
TOTAL_STEPS=7
CURRENT_STEP=0

# -------------------------------------------------------
# Parse flags
# -------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --minimal)  MINIMAL=true ;;
    --yes|-y)   YES_MODE=true ;;
    --help|-h)
      echo "Usage: ./setup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --minimal   Install only the 5 most-used commands"
      echo "  --dry-run   Show what would be installed without doing anything"
      echo "  --yes, -y   Skip interactive prompts (answer yes to all)"
      echo "  --help, -h  Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Run ./setup.sh --help for usage."
      exit 1
      ;;
  esac
done

# Select repo set based on mode
if $MINIMAL; then
  REPOS=("${MINIMAL_REPOS[@]}")
else
  REPOS=("${ALL_REPOS[@]}")
fi

# -------------------------------------------------------
# Output helpers
# -------------------------------------------------------
step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo ""
  echo -e "${BOLD}[Step ${CURRENT_STEP}/${TOTAL_STEPS}]${NC} $1"
  echo -e "${DIM}$(printf '%.0s-' {1..50})${NC}"
}

info()    { echo -e "  ${ARROW} $1"; }
success() { echo -e "  ${CHECK} $1"; }
warn()    { echo -e "  ${WARN} $1"; }
error()   { echo -e "  ${CROSS} $1"; }

dry_run_tag() {
  if $DRY_RUN; then
    echo -e " ${DIM}(dry run)${NC}"
  fi
}

# -------------------------------------------------------
# 1. Check prerequisites
# -------------------------------------------------------
check_prerequisites() {
  step "Checking prerequisites"
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
}

# -------------------------------------------------------
# 2. Create directories
# -------------------------------------------------------
setup_directories() {
  step "Setting up directories$(dry_run_tag)"

  if $DRY_RUN; then
    info "Would create: $COMMANDS_DIR"
    info "Would create: $CLONE_DIR"
    return
  fi

  mkdir -p "$COMMANDS_DIR"
  success "Commands directory ready: $COMMANDS_DIR"

  mkdir -p "$CLONE_DIR"
  success "Hub directory ready: $CLONE_DIR"
}

# -------------------------------------------------------
# 3. Clone or update all Hub repos
# -------------------------------------------------------
sync_repos() {
  local mode_label="all"
  if $MINIMAL; then
    mode_label="minimal (${#REPOS[@]} repos)"
  else
    mode_label="full (${#REPOS[@]} repos)"
  fi

  step "Syncing AI BU Hub repos - ${mode_label}$(dry_run_tag)"

  if $DRY_RUN; then
    for repo in "${REPOS[@]}"; do
      local repo_dir="$CLONE_DIR/$repo"
      if [[ -d "$repo_dir/.git" ]]; then
        info "Would update: $repo"
      else
        info "Would clone:  $repo"
      fi
    done
    return
  fi

  local cloned=0
  local updated=0
  local failed=0

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    if [[ -d "$repo_dir/.git" ]]; then
      if git -C "$repo_dir" pull --quiet 2>/dev/null; then
        success "Updated: $repo"
        updated=$((updated + 1))
      else
        warn "Failed to update $repo (may be offline). Using existing version."
        FAILED_REPOS+=("$repo (update failed)")
        failed=$((failed + 1))
      fi
    else
      if git clone --quiet "https://github.com/$GITHUB_ORG/$repo.git" "$repo_dir" 2>/dev/null; then
        success "Cloned:  $repo"
        cloned=$((cloned + 1))
      else
        warn "Could not clone $repo. It may not exist yet or you may be offline."
        FAILED_REPOS+=("$repo (clone failed)")
        failed=$((failed + 1))
      fi
    fi
  done

  echo ""
  info "Summary: ${GREEN}$cloned cloned${NC}, ${GREEN}$updated updated${NC}, ${YELLOW}$failed skipped${NC}"
}

# -------------------------------------------------------
# 4. Install slash commands
# -------------------------------------------------------
install_commands() {
  step "Installing slash commands$(dry_run_tag)"

  if $DRY_RUN; then
    local would_install=0
    for repo in "${REPOS[@]}"; do
      local repo_dir="$CLONE_DIR/$repo"
      if [[ ! -d "$repo_dir" ]]; then
        continue
      fi
      for cmd_file in "$repo_dir"/commands/*.md "$repo_dir"/*.md; do
        if [[ -f "$cmd_file" ]]; then
          local filename
          filename=$(basename "$cmd_file")
          if [[ "$filename" == "README.md" ]] || [[ "$filename" == "CONTRIBUTING.md" ]] || \
             [[ "$filename" == "LICENSE.md" ]] || [[ "$filename" == "CHANGELOG.md" ]] || \
             [[ "$filename" == "first-steps.md" ]]; then
            continue
          fi
          info "Would install: /$( echo "$filename" | sed 's/\.md$//' )"
          would_install=$((would_install + 1))
        fi
      done
    done
    echo ""
    info "Total: $would_install commands would be installed"
    return
  fi

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
        success "Installed: /$( echo "$filename" | sed 's/\.md$//' )"
        installed=$((installed + 1))
      fi
    done
  done

  echo ""
  info "Total: ${GREEN}$installed${NC} slash commands installed to $COMMANDS_DIR"
}

# -------------------------------------------------------
# 5. Optionally set up MCP servers
# -------------------------------------------------------
setup_mcp_servers() {
  step "Configuring MCP servers$(dry_run_tag)"

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
    read -rp "$(echo -e "  ${ARROW} Set up MCP servers (GitHub, Fetch)? [y/N] ")" mcp_choice
  fi

  if [[ "${mcp_choice,,}" != "y" ]]; then
    info "Skipping MCP server setup. You can configure them later."
    return
  fi

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
        success "  GitHub MCP server (authenticated via gh CLI)"
      fi
      success "  Fetch MCP server"
    else
      warn "Could not configure MCP servers automatically."
      warn "See the ai-bu-mcp-server-kit repo for manual setup instructions."
    fi
    rm -f "$tmp_config"
  else
    warn "Node.js not available. Skipping MCP setup."
    warn "Install Node.js and run setup again, or configure MCP servers manually."
  fi
}

# -------------------------------------------------------
# 6. Optionally install git productivity aliases
# -------------------------------------------------------
setup_git_aliases() {
  step "Git productivity aliases$(dry_run_tag)"

  if $DRY_RUN; then
    info "Would install git aliases: co, br, st, lg, last, unstage, amend"
    return
  fi

  local alias_choice="n"
  if $YES_MODE; then
    alias_choice="y"
  else
    echo ""
    read -rp "$(echo -e "  ${ARROW} Install git productivity aliases? [y/N] ")" alias_choice
  fi

  if [[ "${alias_choice,,}" != "y" ]]; then
    info "Skipping git aliases."
    return
  fi

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
}

# -------------------------------------------------------
# 7. Print summary
# -------------------------------------------------------
print_summary() {
  step "Done"

  if $DRY_RUN; then
    echo ""
    echo -e "  ${BOLD}${YELLOW}DRY RUN COMPLETE${NC}"
    echo -e "  No changes were made. Run without --dry-run to install."
    echo ""
    return
  fi

  # Count installed commands
  local cmd_count=0
  if [[ -d "$COMMANDS_DIR" ]]; then
    cmd_count=$(find "$COMMANDS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  fi

  echo ""
  echo -e "  ${GREEN}${BOLD}AI BU Hub Setup Complete${NC}"
  echo ""
  echo -e "  Slash commands installed:  ${GREEN}${cmd_count}${NC}"
  echo -e "  Commands directory:        $COMMANDS_DIR"
  echo -e "  Hub repos directory:       $CLONE_DIR"

  # Report failures if any
  if [[ ${#FAILED_REPOS[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${YELLOW}${BOLD}Some repos had issues:${NC}"
    for f in "${FAILED_REPOS[@]}"; do
      echo -e "    ${CROSS} $f"
    done
    echo -e "  ${DIM}Run setup.sh again when online to retry.${NC}"
  fi

  if $MINIMAL; then
    echo ""
    echo -e "  ${DIM}Minimal install: only the top 5 commands were installed.${NC}"
    echo -e "  ${DIM}Run setup.sh without --minimal to get everything.${NC}"
  fi

  echo ""
  echo -e "  ${BOLD}Try these first:${NC}"
  echo ""
  echo "  1. claude /briefing      - Get your daily GitHub activity summary"
  echo "  2. claude /polish        - Clean up a rough email or message draft"
  echo "  3. claude /style-check   - Check a blog post against Red Hat style"
  echo "  4. claude /status-report - Generate a weekly status report"
  echo ""
  echo -e "  Run 'claude' in any project directory and use /help to see"
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
  echo -e "${GREEN}${BOLD}AI BU Hub Onboarding Kit${NC}"
  echo -e "Setting up Claude Code with AI BU Hub tools"
  if $DRY_RUN; then
    echo -e "${YELLOW}${BOLD}DRY RUN MODE${NC} - nothing will be changed"
  fi
  if $MINIMAL; then
    echo -e "${BLUE}MINIMAL MODE${NC} - installing top 5 commands only"
  fi

  check_prerequisites
  setup_directories
  sync_repos
  install_commands
  setup_mcp_servers
  setup_git_aliases
  print_summary
}

main
