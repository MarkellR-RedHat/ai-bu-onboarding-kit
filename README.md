# AI BU Onboarding Kit

One command to set up Claude Code with all AI BU Hub tools, MCP servers, and slash commands. Run this and you are configured like everyone else on the team.

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-onboarding-kit.git
cd ai-bu-onboarding-kit
chmod +x setup.sh
./setup.sh
```

That's it. The setup script checks your prerequisites, clones all the Hub tool repos, installs the slash commands, and optionally configures MCP servers and git aliases.

## What gets installed

The setup script pulls from these AI BU Hub repos and installs their slash commands into `~/.claude/commands/`:

| Repo | What it does |
|------|-------------|
| ai-bu-claude-commands | Core slash command collection |
| ai-bu-daily-briefing | Daily GitHub activity summary |
| ai-bu-meeting-notes | Structure raw meeting notes |
| ai-bu-status-report | Generate weekly status reports |
| ai-bu-review-as-persona | Get feedback from a specific perspective |
| ai-bu-style-checker | Check writing against Red Hat style |
| ai-bu-cfp-generator | Draft conference talk proposals |
| ai-bu-slide-outliner | Outline slide decks from a topic |
| ai-bu-prompt-library | Reusable prompt templates |
| ai-bu-git-productivity | Git aliases and workflow shortcuts |
| ai-bu-message-polisher | Clean up rough drafts |
| ai-bu-competitive-watch | Summarize competitor activity |
| ai-bu-upstream-tracker | Track upstream project changes |
| ai-bu-shipped-digest | Summarize recent shipments |
| ai-bu-speed-reader | Summarize long documents |
| ai-bu-mcp-server-kit | MCP server configurations |
| ai-bu-claude-md-templates | CLAUDE.md templates for projects |

### Optional extras

During setup, you can also configure:

- **MCP servers** for GitHub and Fetch (requires Node.js and gh CLI)
- **Git aliases** for common operations (co, br, st, lg, etc.)

## Prerequisites

Required:
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- git

Recommended:
- [GitHub CLI (gh)](https://cli.github.com/) installed and authenticated
- Node.js 18+ and npx (for MCP servers)

## Updating

Pull the latest versions of all commands:

```bash
./update.sh
```

This fetches updates from all Hub repos and reinstalls the slash commands.

## Verifying your setup

Check that everything is installed and working:

```bash
./verify.sh
```

## Uninstalling

Remove all AI BU Hub commands, repos, and configuration:

```bash
./uninstall.sh
```

This only removes what the setup script installed. Claude Code itself is not touched.

## After setup

See [first-steps.md](first-steps.md) for a guided walkthrough of the most useful commands. Start with:

1. `claude /briefing` to see your GitHub activity summary
2. `claude /polish` to clean up a rough email draft
3. `claude /style-check` to review a blog post
4. `claude /status-report` to generate a weekly update

## Project structure

```
ai-bu-onboarding-kit/
  setup.sh          # Main setup script (run this first)
  update.sh         # Pull latest command versions
  uninstall.sh      # Remove everything cleanly
  verify.sh         # Check installation health
  first-steps.md    # Guided walkthrough for new users
  README.md         # This file
```

## Contributing

Found a bug or want to add a feature? Open an issue or submit a PR.

## License

MIT
