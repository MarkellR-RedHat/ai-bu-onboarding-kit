#!/usr/bin/env bash
set -uo pipefail

# ============================================================================
#  AI BU Hub - Update
#  Pull latest versions of all tools. Shows what changed.
#
#  Usage:
#    ./update.sh           Update everything
#    ./update.sh --diff    Show detailed diffs of changed commands
# ============================================================================

GITHUB_ORG="MarkellR-RedHat"
COMMANDS_DIR="$HOME/.claude/commands"
CLONE_DIR="$HOME/.ai-bu-hub"
BACKUP_DIR="$HOME/.ai-bu-hub/.backups/$(date +%Y%m%d-%H%M%S)"

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

# -------------------------------------------------------
# Colors
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

CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
WARN="${YELLOW}!${NC}"
ARROW="${CYAN}>${NC}"
PLUS="${GREEN}+${NC}"
MINUS="${RED}-${NC}"
CHANGE="${YELLOW}~${NC}"

SHOW_DIFF=false
for arg in "$@"; do
  case "$arg" in
    --diff|-d)  SHOW_DIFF=true ;;
    --help|-h)
      echo "Usage: ./update.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --diff, -d   Show detailed diffs of changed commands"
      echo "  --help, -h   Show this help"
      exit 0
      ;;
  esac
done

# Tracking
UPDATED_REPOS=0
CLONED_REPOS=0
FAILED_REPOS=0
NEW_COMMANDS=()
UPDATED_COMMANDS=()
REMOVED_COMMANDS=()

# -------------------------------------------------------
# Output helpers
# -------------------------------------------------------
info()    { echo -e "  ${ARROW} $1"; }
success() { echo -e "  ${CHECK} $1"; }
warn()    { echo -e "  ${WARN} $1"; }
fail()    { echo -e "  ${CROSS} $1"; }

# Skip list for non-command files
skip_files="README.md CONTRIBUTING.md LICENSE.md CHANGELOG.md first-steps.md commands-cheatsheet.md"

is_skip_file() {
  [[ "$skip_files" == *"$1"* ]]
}

# -------------------------------------------------------
# Main
# -------------------------------------------------------
main() {
  echo ""
  echo -e "  ${CYAN}${BOLD}AI BU Hub -- Update${NC}"
  echo -e "  ${DIM}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
  echo ""

  if [[ ! -d "$CLONE_DIR" ]]; then
    fail "Hub repos not found at $CLONE_DIR"
    fail "Run setup.sh first."
    exit 1
  fi

  # ---- Back up current commands ----
  echo -e "  ${BOLD}${WHITE}Backing up current commands${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"

  mkdir -p "$BACKUP_DIR"
  if [[ -d "$COMMANDS_DIR" ]]; then
    local backup_count=0
    for f in "$COMMANDS_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      cp "$f" "$BACKUP_DIR/" 2>/dev/null && backup_count=$((backup_count + 1))
    done
    success "Backed up ${backup_count} commands to ${DIM}$BACKUP_DIR${NC}"
  fi

  # ---- Snapshot current command checksums ----
  declare -A OLD_CHECKSUMS
  if [[ -d "$COMMANDS_DIR" ]]; then
    for f in "$COMMANDS_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      local fname
      fname=$(basename "$f")
      OLD_CHECKSUMS[$fname]=$(md5 -q "$f" 2>/dev/null || md5sum "$f" 2>/dev/null | cut -d' ' -f1 || echo "")
    done
  fi

  # Snapshot current command list
  declare -A OLD_COMMANDS
  if [[ -d "$COMMANDS_DIR" ]]; then
    for f in "$COMMANDS_DIR"/*.md; do
      [[ -f "$f" ]] || continue
      OLD_COMMANDS[$(basename "$f")]=1
    done
  fi

  # ---- Pull repos ----
  echo ""
  echo -e "  ${BOLD}${WHITE}Pulling latest from ${#REPOS[@]} repos${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    if [[ -d "$repo_dir/.git" ]]; then
      # Get current hash for change detection
      local old_hash
      old_hash=$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null || echo "unknown")

      if git -C "$repo_dir" pull --quiet 2>/dev/null; then
        local new_hash
        new_hash=$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null || echo "unknown")
        if [[ "$old_hash" != "$new_hash" ]]; then
          # Show what changed
          local commit_count
          commit_count=$(git -C "$repo_dir" rev-list "$old_hash".."$new_hash" --count 2>/dev/null || echo "?")
          success "${repo} ${DIM}${commit_count} new commit(s)${NC}"

          # Show commit summaries
          git -C "$repo_dir" log --oneline "$old_hash".."$new_hash" 2>/dev/null | while read -r line; do
            echo -e "    ${DIM}${line}${NC}"
          done
        else
          success "${repo} ${DIM}already up to date${NC}"
        fi
        UPDATED_REPOS=$((UPDATED_REPOS + 1))
      else
        warn "${repo} ${DIM}update failed${NC}"
        FAILED_REPOS=$((FAILED_REPOS + 1))
      fi
    else
      info "New repo: $repo -- cloning..."
      if git clone --quiet "https://github.com/$GITHUB_ORG/$repo.git" "$repo_dir" 2>/dev/null; then
        success "${repo} ${DIM}cloned${NC}"
        CLONED_REPOS=$((CLONED_REPOS + 1))
      else
        warn "${repo} ${DIM}clone failed${NC}"
        FAILED_REPOS=$((FAILED_REPOS + 1))
      fi
    fi
  done

  # ---- Reinstall commands ----
  echo ""
  echo -e "  ${BOLD}${WHITE}Reinstalling slash commands${NC}"
  echo -e "  ${DIM}$(printf '%.0s-' $(seq 1 50))${NC}"

  local installed=0
  declare -A NEW_COMMAND_SET

  for repo in "${REPOS[@]}"; do
    local repo_dir="$CLONE_DIR/$repo"
    [[ ! -d "$repo_dir" ]] && continue

    for cmd_file in "$repo_dir"/commands/*.md "$repo_dir"/*.md; do
      [[ -f "$cmd_file" ]] || continue
      local filename
      filename=$(basename "$cmd_file")
      is_skip_file "$filename" && continue

      NEW_COMMAND_SET[$filename]=1
      cp "$cmd_file" "$COMMANDS_DIR/$filename"
      installed=$((installed + 1))

      # Track what changed
      local cmd_name
      cmd_name=$(echo "$filename" | sed 's/\.md$//')
      if [[ -z "${OLD_COMMANDS[$filename]:-}" ]]; then
        NEW_COMMANDS+=("/$cmd_name")
      else
        # Check if content changed
        local new_checksum
        new_checksum=$(md5 -q "$COMMANDS_DIR/$filename" 2>/dev/null || md5sum "$COMMANDS_DIR/$filename" 2>/dev/null | cut -d' ' -f1 || echo "")
        if [[ -n "${OLD_CHECKSUMS[$filename]:-}" ]] && [[ "$new_checksum" != "${OLD_CHECKSUMS[$filename]}" ]]; then
          UPDATED_COMMANDS+=("/$cmd_name")

          # Show diff if requested
          if $SHOW_DIFF && [[ -f "$BACKUP_DIR/$filename" ]]; then
            echo -e "  ${CHANGE} /${cmd_name} changed:"
            diff --color=auto "$BACKUP_DIR/$filename" "$COMMANDS_DIR/$filename" 2>/dev/null | head -20 | while read -r line; do
              echo "    $line"
            done
            echo ""
          fi
        fi
      fi
    done
  done

  # Detect removed commands
  for old_file in "${!OLD_COMMANDS[@]}"; do
    if [[ -z "${NEW_COMMAND_SET[$old_file]:-}" ]]; then
      local cmd_name
      cmd_name=$(echo "$old_file" | sed 's/\.md$//')
      REMOVED_COMMANDS+=("/$cmd_name")
    fi
  done

  success "Reinstalled ${GREEN}${installed}${NC} slash commands"

  # ---- Change summary ----
  echo ""
  echo -e "  ${BOLD}${WHITE}=====================================================${NC}"
  echo -e "  ${BOLD}${WHITE}  Update Summary${NC}"
  echo -e "  ${BOLD}${WHITE}=====================================================${NC}"
  echo ""

  printf "  %-25s ${GREEN}${BOLD}%d${NC}\n" "Repos updated:" "$UPDATED_REPOS"
  if [[ $CLONED_REPOS -gt 0 ]]; then
    printf "  %-25s ${GREEN}${BOLD}%d${NC}\n" "Repos newly cloned:" "$CLONED_REPOS"
  fi
  if [[ $FAILED_REPOS -gt 0 ]]; then
    printf "  %-25s ${YELLOW}${BOLD}%d${NC}\n" "Repos failed:" "$FAILED_REPOS"
  fi
  printf "  %-25s ${BOLD}%d${NC}\n" "Commands installed:" "$installed"

  if [[ ${#NEW_COMMANDS[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${PLUS} ${BOLD}New commands:${NC}"
    for cmd in "${NEW_COMMANDS[@]}"; do
      echo -e "    ${GREEN}+ ${cmd}${NC}"
    done
  fi

  if [[ ${#UPDATED_COMMANDS[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${CHANGE} ${BOLD}Updated commands:${NC}"
    for cmd in "${UPDATED_COMMANDS[@]}"; do
      echo -e "    ${YELLOW}~ ${cmd}${NC}"
    done
    if ! $SHOW_DIFF; then
      echo -e "    ${DIM}Run with --diff to see what changed${NC}"
    fi
  fi

  if [[ ${#REMOVED_COMMANDS[@]} -gt 0 ]]; then
    echo ""
    echo -e "  ${MINUS} ${BOLD}Removed commands:${NC}"
    for cmd in "${REMOVED_COMMANDS[@]}"; do
      echo -e "    ${RED}- ${cmd}${NC}"
    done
  fi

  if [[ ${#NEW_COMMANDS[@]} -eq 0 && ${#UPDATED_COMMANDS[@]} -eq 0 && ${#REMOVED_COMMANDS[@]} -eq 0 ]]; then
    echo ""
    echo -e "  ${DIM}No command changes detected. Everything is up to date.${NC}"
  fi

  echo ""
  echo -e "  ${DIM}Backup saved to: $BACKUP_DIR${NC}"
  echo ""
}

main
