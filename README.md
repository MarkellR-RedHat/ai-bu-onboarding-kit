# AI BU Hub

130+ productivity commands for the Red Hat AI BU. One command to install them all.

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-onboarding-kit.git
cd ai-bu-onboarding-kit
./setup.sh
```

## What you get in 5 commands

```
$ claude /read-the-room
→ Paste any message. Get back what is really being said, the emotional tone,
  and a suggested response strategy.

$ claude /briefing
→ Morning GitHub summary: PRs to review, PRs waiting on you, recent mentions,
  and a prioritized list of what to tackle first.

$ claude /polish "rough draft of your message here"
→ Same meaning, tighter language, more professional. Your voice stays intact.

$ claude /status-report
→ Weekly status report pulled from your Git commits and merged PRs. No more
  Friday afternoon scrambling.

$ claude /speedread https://arxiv.org/abs/some-paper
→ One-paragraph summary, key findings, and a "read it or skip it" verdict
  in under 10 seconds.
```

That is 5 of the 130+ commands. See the [full cheatsheet](commands-cheatsheet.md) for the rest.

## Setup modes

```bash
./setup.sh              # Full install, all 17 tools
./setup.sh --minimal    # Top 5 tools only (fastest)
./setup.sh --pick       # Interactive menu, choose what you want
./setup.sh --dry-run    # See what would happen without changing anything
./setup.sh --yes        # Skip prompts, accept all defaults
```

## What the setup installs

The setup script handles everything in one pass:

1. Detects your OS and checks prerequisites
2. Clones all 17 Hub tool repos
3. Registers 130+ slash commands into Claude Code
4. Configures MCP servers (GitHub, Fetch)
5. Optionally sets up git productivity aliases
6. Shows a summary of everything installed

```
~/.claude/
  commands/                  Slash commands (130+ .md files)
    briefing.md                /briefing
    polish.md                  /polish
    style-check.md             /style-check
    status-report.md           /status-report
    read-the-room.md           /read-the-room
    speedread.md               /speedread
    ...                        (120+ more)
  settings.json              MCP server config (GitHub, Fetch)

~/.ai-bu-hub/                Source repos (cloned from GitHub)
  ai-bu-claude-commands/       Core engineering commands
  ai-bu-daily-briefing/        Daily workflow commands
  ai-bu-meeting-notes/         Meeting commands
  ai-bu-message-polisher/      Communication commands
  ai-bu-style-checker/         Style and tone commands
  ai-bu-status-report/         Reporting commands
  ai-bu-review-as-persona/     Persona review commands
  ai-bu-cfp-generator/         Conference proposal commands
  ai-bu-slide-outliner/        Presentation commands
  ai-bu-speed-reader/          Research commands
  ai-bu-competitive-watch/     Competitive intel commands
  ai-bu-upstream-tracker/      Upstream tracking commands
  ai-bu-shipped-digest/        Shipping digest commands
  ai-bu-claude-md-templates/   Template commands
  ai-bu-prompt-library/        Reusable prompt templates
  ai-bu-git-productivity/      Git aliases and shortcuts
  ai-bu-mcp-server-kit/        MCP server configurations
```

## Prerequisites

**Required:**
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- git

**Recommended:**
- [GitHub CLI (gh)](https://cli.github.com/) installed and authenticated
- Node.js 18+ (for MCP servers)

## After setup

Start here: [first-steps.md](first-steps.md) walks you through the most impressive commands in 10 minutes.

**The commands you will reach for most:**

| Command | What it does |
|---------|-------------|
| `/briefing` | Morning GitHub activity summary |
| `/polish` | Clean up any rough draft |
| `/read-the-room` | Decode what a message is really saying |
| `/status-report` | Weekly status report from Git history |
| `/speedread` | Summarize any long document |
| `/style-check` | Check writing against Red Hat style |

**The commands that will surprise you:**

| Command | What it does |
|---------|-------------|
| `/meeting-cancel` | Assesses if a meeting should be an email |
| `/cfp-reviewer` | Simulates a CFP reviewer scoring your proposal |
| `/slide-hooks` | Generates opening hooks for a presentation |
| `/red-team` | Adversarial review to find weaknesses |
| `/speedread-verdict` | "Read it or skip it" in 10 seconds |
| `/what-next` | Figures out the highest-impact thing to work on |

## Verify your setup

```bash
./verify.sh
```

You will see a full diagnostic with pass/fail status for every component, a health score, and specific fix instructions for any issues.

## Update

```bash
./update.sh           # Pull the latest versions of everything
./update.sh --diff    # Also show line-by-line diffs of changed commands
```

## Uninstall

```bash
./uninstall.sh
```

Removes all AI BU Hub commands, repos, and configuration. Claude Code itself is not touched.

## Project structure

```
ai-bu-onboarding-kit/
  setup.sh                 One-command setup (start here)
  verify.sh                Health check dashboard
  update.sh                Pull latest versions
  uninstall.sh             Clean removal
  first-steps.md           10-minute guided walkthrough
  commands-cheatsheet.md   Full command reference (130+ commands)
  README.md                This file
```

## Contributing

Found a bug or want to improve something? Open an issue or submit a PR on this repo.

To add a new tool to the onboarding kit, add its repo name to the `ALL_REPOS` array in `setup.sh`.

## License

MIT
