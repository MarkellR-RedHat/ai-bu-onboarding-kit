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

### Setup options

```bash
./setup.sh              # Full install with interactive prompts
./setup.sh --minimal    # Install only the top 5 commands
./setup.sh --dry-run    # Preview what would be installed (no changes made)
./setup.sh --yes        # Skip prompts, answer yes to everything
```

## What gets installed

Here is a visual map of everything the setup script puts on your system:

```
~/.claude/
  commands/                  # Slash commands (used by Claude Code)
    briefing.md              #   /briefing - daily GitHub summary
    polish.md                #   /polish - clean up rough drafts
    style-check.md           #   /style-check - Red Hat writing style
    status-report.md         #   /status-report - weekly status report
    meeting-notes.md         #   /meeting-notes - structure raw notes
    review-as-persona.md     #   /review-as-persona - perspective feedback
    cfp-generator.md         #   /cfp-generator - conference proposals
    slide-outliner.md        #   /slide-outliner - slide deck outlines
    competitive-watch.md     #   /competitive-watch - competitor activity
    upstream-tracker.md      #   /upstream-tracker - upstream changes
    shipped-digest.md        #   /shipped-digest - recent shipments
    speed-reader.md          #   /speed-reader - summarize documents
    ...                      #   (plus any additional commands from repos)
  settings.json              # MCP server config (GitHub, Fetch)

~/.ai-bu-hub/                # Source repos (cloned from GitHub)
  ai-bu-claude-commands/     #   Core command collection
  ai-bu-daily-briefing/      #   Briefing command source
  ai-bu-meeting-notes/       #   Meeting notes source
  ai-bu-status-report/       #   Status report source
  ai-bu-review-as-persona/   #   Persona review source
  ai-bu-style-checker/       #   Style checker source
  ai-bu-message-polisher/    #   Message polisher source
  ai-bu-cfp-generator/       #   CFP generator source
  ai-bu-slide-outliner/      #   Slide outliner source
  ai-bu-prompt-library/      #   Reusable prompt templates
  ai-bu-git-productivity/    #   Git aliases and shortcuts
  ai-bu-competitive-watch/   #   Competitive watch source
  ai-bu-upstream-tracker/    #   Upstream tracker source
  ai-bu-shipped-digest/      #   Shipped digest source
  ai-bu-speed-reader/        #   Speed reader source
  ai-bu-mcp-server-kit/      #   MCP server configurations
  ai-bu-claude-md-templates/ #   CLAUDE.md templates
```

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

You will see a pass/fail report with a summary score showing how many checks passed out of the total.

## Uninstalling

Remove all AI BU Hub commands, repos, and configuration:

```bash
./uninstall.sh
```

This only removes what the setup script installed. Claude Code itself is not touched.

## After setup

See [first-steps.md](first-steps.md) for an interactive walkthrough that builds step by step, including expected output for each command and a 5-minute challenge at the end.

For a quick reference of all commands, see [commands-cheatsheet.md](commands-cheatsheet.md).

Start with:

1. `claude /briefing` to see your GitHub activity summary
2. `claude /polish` to clean up a rough email draft
3. `claude /style-check` to review a blog post
4. `claude /status-report` to generate a weekly update

## Project structure

```
ai-bu-onboarding-kit/
  setup.sh                 # Main setup script (run this first)
  update.sh                # Pull latest command versions
  uninstall.sh             # Remove everything cleanly
  verify.sh                # Check installation health
  first-steps.md           # Interactive walkthrough for new users
  commands-cheatsheet.md   # One-page command reference
  README.md                # This file
```

## Contributing

Found a bug or want to add a feature? Open an issue or submit a PR.

## License

MIT
