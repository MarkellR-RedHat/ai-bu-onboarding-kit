#!/usr/bin/env bash
set -euo pipefail

# AI BU Hub Onboarding Kit - Update Script
# Pulls the latest versions of all commands from Hub repos.

GITHUB_ORG="MarkellR-RedHat"
COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"

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
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

main() {
  echo ""
  echo -e "${GREEN}AI BU Hub - Update${NC}"
  echo ""

  if [[ ! -d "$CLONE_DIR" ]]; then
    error "Hub repos not found at $CLONE_DIR"
    error "Run setup.sh first."
    exit 1
  fi

  local updated=0
  local cloned=0
  local failed=0

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    if [[ -d "$repo_dir/.git" ]]; then
      if git -C "$repo_dir" pull --quiet 2>/dev/null; then
        updated=$((updated + 1))
      else
        warn "Failed to update $repo"
        failed=$((failed + 1))
      fi
    else
      info "New repo found: $repo. Cloning..."
      if git clone --quiet "https://github.com/$GITHUB_ORG/$repo.git" "$repo_dir" 2>/dev/null; then
        cloned=$((cloned + 1))
      else
        warn "Could not clone $repo"
        failed=$((failed + 1))
      fi
    fi
  done

  success "Repos: $updated updated, $cloned newly cloned, $failed skipped"

  # Reinstall commands
  info "Reinstalling slash commands..."
  local installed=0

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
        cp "$cmd_file" "$COMMANDS_DIR/$filename"
        installed=$((installed + 1))
      fi
    done
  done

  success "Reinstalled $installed slash commands"
  echo ""
  echo -e "${GREEN}Update complete.${NC}"
  echo ""
}

main "$@"
