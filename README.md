# AI BU Onboarding Kit

One command. Under 3 minutes. 100+ slash commands for Claude Code.

This is the setup kit for the AI BU Hub tool suite. It clones 17 tool repos, installs every slash command, configures MCP servers, and gets you fully operational. Run it once and you are configured like the rest of the team.

## Quick Start

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-onboarding-kit.git
cd ai-bu-onboarding-kit
chmod +x setup.sh
./setup.sh
```

That is the whole process. The setup script handles everything:

1. Detects your OS and checks prerequisites
2. Clones all 17 Hub tool repos
3. Installs 100+ slash commands into Claude Code
4. Configures MCP servers (GitHub, Fetch)
5. Optionally sets up git productivity aliases
6. Shows a summary dashboard of everything installed

### Setup Modes

```bash
./setup.sh              # Full install, all 17 tools
./setup.sh --minimal    # Top 5 tools only (fastest)
./setup.sh --pick       # Interactive menu, choose what you want
./setup.sh --dry-run    # See what would happen without changing anything
./setup.sh --yes        # Skip prompts, accept all defaults
```

## What You Get

17 specialized tools, 100+ slash commands, organized by workflow:

```
DAILY WORKFLOW                    COMMUNICATION
  /briefing                         /polish
  /standup                          /shorten
  /catch-me-up                      /tone-shift
  /risk-radar                       /read-the-room
  /status-report                    /bad-news
  /executive-summary                /decline-politely
                                    /escalation
MEETINGS                           /follow-up
  /meeting-notes
  /action-items                   STYLE AND QUALITY
  /pre-brief                       /style-check
  /meeting-cancel                   /style-fix
  /decision-log                     /style-score
  /raci                             /tone-check

CONTENT CREATION                  INTELLIGENCE
  /cfp                              /whats-new
  /slides                           /landscape
  /blog-from-pr                     /upstream
  /draft-announcement               /shipped
  /write-docs                       /battlecard

RESEARCH                          ENGINEERING
  /speedread                        /tldr-repo
  /speedread-verdict                /what-next
  /speedread-extract                /retro
  /review-as                        /demo-prep
  /red-team                         /release-notes
```

See [commands-cheatsheet.md](commands-cheatsheet.md) for the full reference with descriptions.

## What the setup installs

```
~/.claude/
  commands/                  Slash commands (100+ .md files)
    briefing.md                /briefing - daily GitHub summary
    polish.md                  /polish - clean up rough drafts
    style-check.md             /style-check - Red Hat writing style
    status-report.md           /status-report - weekly status report
    read-the-room.md           /read-the-room - decode messages
    speedread.md               /speedread - summarize documents
    ...                        (90+ more commands)
  settings.json              MCP server config (GitHub, Fetch)

~/.ai-bu-hub/                Source repos (cloned from GitHub)
  ai-bu-claude-commands/       12 core engineering commands
  ai-bu-daily-briefing/         7 daily workflow commands
  ai-bu-meeting-notes/         10 meeting commands
  ai-bu-status-report/          6 reporting commands
  ai-bu-message-polisher/      10 communication commands
  ai-bu-style-checker/          8 style and tone commands
  ai-bu-review-as-persona/      8 persona review commands
  ai-bu-cfp-generator/          9 conference proposal commands
  ai-bu-slide-outliner/         9 presentation commands
  ai-bu-speed-reader/           9 research commands
  ai-bu-competitive-watch/      9 competitive intel commands
  ai-bu-upstream-tracker/        5 upstream tracking commands
  ai-bu-shipped-digest/         6 shipping digest commands
  ai-bu-claude-md-templates/     2 template commands
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

## Verify Your Setup

Run the health check dashboard to confirm everything is working:

```bash
./verify.sh
```

You will see a full diagnostic with pass/fail status for every component, a health score, and specific fix instructions for any issues:

```
  AI BU Hub -- Health Check Dashboard

  Prerequisites
  --------------------------------------------------
  PASS  Claude Code                          v1.0.31
  PASS  git                                  2.45.0
  PASS  GitHub CLI (gh)                      2.54.0
  PASS  Node.js                              v22.4.0

  Hub Repos (17 expected)
  --------------------------------------------------
  PASS  ai-bu-claude-commands                12 commands
  PASS  ai-bu-daily-briefing                 7 commands
  ...

  =====================================================
    Health Check Results
  =====================================================

  Health: ██████████████████████████████  100%

  [OK] ALL SYSTEMS GO
```

## Update

Pull the latest versions of everything:

```bash
./update.sh
```

The update script shows what changed since your last update: new commands added, existing commands modified, and repos with new commits. It backs up your current commands before making changes.

```bash
./update.sh --diff    # Also show line-by-line diffs of changed commands
```

## Uninstall

Remove all AI BU Hub commands, repos, and configuration:

```bash
./uninstall.sh
```

This only removes what setup installed. Claude Code itself is not touched.

## After Setup

Start here: [first-steps.md](first-steps.md) is a 10-minute walkthrough that builds step by step, starting with the most impressive commands and working toward power-user workflows.

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

## Project Structure

```
ai-bu-onboarding-kit/
  setup.sh                 One-command setup (start here)
  verify.sh                Health check dashboard
  update.sh                Pull latest versions
  uninstall.sh             Clean removal
  first-steps.md           10-minute guided walkthrough
  commands-cheatsheet.md   Full command reference (100+ commands)
  README.md                This file
```

## Contributing

Found a bug or want to improve something? Open an issue or submit a PR on this repo.

To add a new tool to the onboarding kit, add its repo name to the `ALL_REPOS` array in `setup.sh`.

## License

MIT
