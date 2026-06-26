#!/usr/bin/env bash
set -euo pipefail

# AI BU Hub Onboarding Kit - Verify Script
# Checks that everything is installed correctly and working.

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
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC}  $1"; }
fail() { echo -e "  ${RED}FAIL${NC}  $1"; }
skip() { echo -e "  ${YELLOW}SKIP${NC}  $1"; }

main() {
  echo ""
  echo -e "${BLUE}AI BU Hub - Installation Verification${NC}"
  echo ""

  local total=0
  local passed=0
  local failed=0

  # Check Claude Code
  total=$((total + 1))
  if command -v claude &>/dev/null; then
    pass "Claude Code is installed"
    passed=$((passed + 1))
  else
    fail "Claude Code is not installed"
    failed=$((failed + 1))
  fi

  # Check git
  total=$((total + 1))
  if command -v git &>/dev/null; then
    pass "git is installed"
    passed=$((passed + 1))
  else
    fail "git is not installed"
    failed=$((failed + 1))
  fi

  # Check gh CLI
  total=$((total + 1))
  if command -v gh &>/dev/null; then
    pass "GitHub CLI (gh) is installed"
    passed=$((passed + 1))
  else
    fail "GitHub CLI (gh) is not installed"
    failed=$((failed + 1))
  fi

  # Check Node.js
  total=$((total + 1))
  if command -v node &>/dev/null; then
    pass "Node.js is installed ($(node --version))"
    passed=$((passed + 1))
  else
    fail "Node.js is not installed"
    failed=$((failed + 1))
  fi

  # Check commands directory
  total=$((total + 1))
  if [[ -d "$COMMANDS_DIR" ]]; then
    local cmd_count
    cmd_count=$(find "$COMMANDS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    pass "Commands directory exists ($cmd_count commands found)"
    passed=$((passed + 1))
  else
    fail "Commands directory not found: $COMMANDS_DIR"
    failed=$((failed + 1))
  fi

  # Check Hub repos directory
  total=$((total + 1))
  if [[ -d "$CLONE_DIR" ]]; then
    pass "Hub repos directory exists: $CLONE_DIR"
    passed=$((passed + 1))
  else
    fail "Hub repos directory not found: $CLONE_DIR"
    failed=$((failed + 1))
  fi

  # Check individual repos
  echo ""
  echo -e "${BLUE}Hub Repos:${NC}"
  for repo in "${REPOS[@]}"; do
    total=$((total + 1))
    if [[ -d "$CLONE_DIR/$repo/.git" ]]; then
      pass "$repo"
      passed=$((passed + 1))
    else
      fail "$repo (not cloned)"
      failed=$((failed + 1))
    fi
  done

  # Check MCP configuration
  echo ""
  echo -e "${BLUE}MCP Servers:${NC}"
  if [[ -f "$MCP_CONFIG" ]]; then
    if command -v node &>/dev/null; then
      # Check for GitHub MCP
      total=$((total + 1))
      if node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); process.exit(c.mcpServers && c.mcpServers.github ? 0 : 1)" 2>/dev/null; then
        pass "GitHub MCP server configured"
        passed=$((passed + 1))
      else
        skip "GitHub MCP server not configured (optional)"
      fi

      # Check for Fetch MCP
      total=$((total + 1))
      if node -e "const c=JSON.parse(require('fs').readFileSync('$MCP_CONFIG','utf8')); process.exit(c.mcpServers && c.mcpServers.fetch ? 0 : 1)" 2>/dev/null; then
        pass "Fetch MCP server configured"
        passed=$((passed + 1))
      else
        skip "Fetch MCP server not configured (optional)"
      fi
    else
      skip "Cannot check MCP config without Node.js"
    fi
  else
    skip "No MCP configuration file found (optional)"
  fi

  # Check gh auth
  echo ""
  echo -e "${BLUE}Authentication:${NC}"
  total=$((total + 1))
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    pass "GitHub CLI is authenticated"
    passed=$((passed + 1))
  else
    fail "GitHub CLI is not authenticated (run: gh auth login)"
    failed=$((failed + 1))
  fi

  # Summary
  echo ""
  echo -e "${BLUE}============================================${NC}"
  echo -e "  Results: ${GREEN}$passed passed${NC}, ${RED}$failed failed${NC} (out of $total checks)"
  echo -e "${BLUE}============================================${NC}"
  echo ""

  if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}Everything looks good. You are ready to go.${NC}"
  else
    echo -e "${YELLOW}Some checks failed. Run setup.sh to fix, or see the output above.${NC}"
  fi

  echo ""
  exit $failed
}

main "$@"
