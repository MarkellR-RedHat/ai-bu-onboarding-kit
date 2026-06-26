#!/usr/bin/env bash
set -euo pipefail

# AI BU Hub Onboarding Kit - Uninstall Script
# Removes all AI BU Hub commands, repos, and configuration.

COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
MCP_CONFIG="$HOME/.claude/settings.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

main() {
  echo ""
  echo -e "${YELLOW}AI BU Hub - Uninstall${NC}"
  echo ""
  echo "This will remove:"
  echo "  - All AI BU Hub slash commands from $COMMANDS_DIR"
  echo "  - All cloned Hub repos from $CLONE_DIR"
  echo "  - MCP server entries added by setup (GitHub, Fetch)"
  echo ""
  read -rp "Are you sure? [y/N] " confirm
  if [[ "${confirm,,}" != "y" ]]; then
    info "Uninstall cancelled."
    exit 0
  fi

  echo ""

  # Remove slash commands that came from Hub repos
  if [[ -d "$CLONE_DIR" ]]; then
    info "Removing Hub slash commands..."
    local removed=0
    for repo_dir in "$CLONE_DIR"/*/; do
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
          if [[ -f "$COMMANDS_DIR/$filename" ]]; then
            rm "$COMMANDS_DIR/$filename"
            removed=$((removed + 1))
          fi
        fi
      done
    done
    success "Removed $removed slash commands"
  fi

  # Remove cloned repos
  if [[ -d "$CLONE_DIR" ]]; then
    info "Removing cloned Hub repos..."
    rm -rf "$CLONE_DIR"
    success "Removed $CLONE_DIR"
  else
    info "No Hub repos directory found."
  fi

  # Clean up MCP config
  if [[ -f "$MCP_CONFIG" ]] && command -v node &>/dev/null; then
    info "Cleaning up MCP server configuration..."
    local tmp_config
    tmp_config=$(mktemp)
    node -e "
      const fs = require('fs');
      let config = {};
      try { config = JSON.parse(fs.readFileSync('${MCP_CONFIG}', 'utf8')); } catch(e) {}
      if (config.mcpServers) {
        delete config.mcpServers['github'];
        delete config.mcpServers['fetch'];
        if (Object.keys(config.mcpServers).length === 0) {
          delete config.mcpServers;
        }
      }
      if (Object.keys(config).length === 0) {
        fs.unlinkSync('${MCP_CONFIG}');
        console.log('DELETED');
      } else {
        fs.writeFileSync('${tmp_config}', JSON.stringify(config, null, 2));
        console.log('UPDATED');
      }
    " 2>/dev/null && {
      if [[ -f "$tmp_config" ]] && [[ -s "$tmp_config" ]]; then
        cp "$tmp_config" "$MCP_CONFIG"
      fi
    }
    rm -f "$tmp_config"
    success "MCP configuration cleaned up"
  fi

  # Remove git aliases (only the ones we set)
  info "Removing git aliases..."
  for alias in co br st lg last unstage amend; do
    git config --global --unset "alias.$alias" 2>/dev/null || true
  done
  success "Git aliases removed"

  echo ""
  echo -e "${GREEN}Uninstall complete.${NC}"
  echo ""
  echo "Claude Code itself was not removed. Only AI BU Hub"
  echo "commands and configuration were cleaned up."
  echo ""
}

main "$@"
