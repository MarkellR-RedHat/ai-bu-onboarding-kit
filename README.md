# AI BU Hub

**You spend half your week on work about work.** Status reports, meeting prep, email wordsmithing, catching up on PRs you missed, figuring out what changed upstream. The engineering is the easy part.

AI BU Hub is 122 slash commands across 17 tools that plug directly into Claude Code. One script, one minute, zero configuration files to edit by hand.

```bash
git clone https://github.com/MarkellR-RedHat/ai-bu-onboarding-kit.git
cd ai-bu-onboarding-kit
./setup.sh
```

That's it. Open Claude Code and type `/briefing` to see it work.

---

## What you get

| Category | Commands | What they do |
|----------|:--------:|--------------|
| **Morning workflow** | 7 | Daily briefing, standup prep, risk radar, team pulse |
| **Message polish** | 10 | Clean up emails, Slack messages, PR descriptions |
| **Style and tone** | 8 | Red Hat style checker, auto-fixer, tone shifter |
| **Meeting support** | 7 | Notes, agendas, action items, "should this be an email?" |
| **Status reports** | 6 | Weekly reports, executive summaries, sprint recaps |
| **Conference talks** | 7 | CFP drafts, reviewer simulation, abstract polishing |
| **Presentations** | 7 | Slide outlines, speaker notes, opening hooks |
| **Research** | 5 | Summarize docs, papers, repos in seconds |
| **Persona reviews** | 5 | Get feedback from any persona you describe |
| **Competitive intel** | 7 | Track competitors, generate battlecards |
| **Upstream tracking** | 5 | Monitor upstream projects for breaking changes |
| **Shipped digest** | 4 | Summarize what your team shipped this week |
| **Code and repo** | 20+ | Red team, write docs, debug, refactor, review |
| **Project templates** | 8 | CLAUDE.md templates for different project types |
| **Git productivity** | - | Aliases and shortcuts installed globally |
| **MCP servers** | - | GitHub and Fetch servers configured automatically |
| **Prompt library** | 16 | Reusable prompt templates for common patterns |

**17 tools. 122 commands. All registered in Claude Code as slash commands.**

---

## Five to try right now

```
$ claude /read-the-room
  Paste any message. Get back what is really being said,
  the emotional tone, and a suggested response strategy.

$ claude /briefing
  Morning GitHub summary: PRs to review, PRs waiting on you,
  recent mentions, and a prioritized list of what to tackle first.

$ claude /polish "rough draft of your message here"
  Same meaning, tighter language, more professional.
  Your voice stays intact.

$ claude /status-report
  Weekly status report pulled from your Git commits and merged PRs.
  No more Friday afternoon scrambling.

$ claude /speedread https://arxiv.org/abs/some-paper
  One-paragraph summary, key findings, and a "read it or skip it"
  verdict in under 10 seconds.
```

Full command reference: [commands-cheatsheet.md](commands-cheatsheet.md)

---

## Setup modes

```bash
./setup.sh              # Full install, all 17 tools
./setup.sh --minimal    # Top 5 tools only (fastest)
./setup.sh --pick       # Interactive menu, choose what you want
./setup.sh --dry-run    # Preview without changing anything
./setup.sh --yes        # Skip prompts, accept all defaults
```

### What setup.sh does

In one pass:

1. Detects your OS and checks prerequisites (Claude Code, git, gh, Node.js)
2. Clones all 17 tool repos into `~/.ai-bu-hub/`
3. Registers 122 slash commands into `~/.claude/commands/`
4. Configures MCP servers (GitHub, Fetch) in `~/.claude/settings.json`
5. Optionally installs git productivity aliases
6. Shows a summary of everything installed with next steps

### Prerequisites

**Required:**
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- git

**Recommended:**
- [GitHub CLI (gh)](https://cli.github.com/) installed and authenticated
- Node.js 18+ (for MCP servers)

---

## After setup

Run [first-steps.md](first-steps.md) for a 10-minute guided walkthrough of the most useful commands.

### Most used

| Command | What it does |
|---------|-------------|
| `/briefing` | Morning GitHub activity summary |
| `/polish` | Clean up any rough draft |
| `/read-the-room` | Decode what a message is really saying |
| `/status-report` | Weekly status report from Git history |
| `/speedread` | Summarize any long document |
| `/style-check` | Check writing against Red Hat style |

### Worth trying

| Command | What it does |
|---------|-------------|
| `/meeting-cancel` | Decide if a meeting should be an email |
| `/cfp-reviewer` | Simulate a CFP reviewer scoring your proposal |
| `/slide-hooks` | Generate opening hooks for a presentation |
| `/red-team` | Adversarial review to find weaknesses in your content |
| `/speedread-verdict` | "Read it or skip it" in 10 seconds |
| `/what-next` | Identify the highest-impact thing to work on next |

---

## Verify, update, uninstall

```bash
./verify.sh             # Health check: pass/fail for every component
./update.sh             # Pull latest versions of all tools
./update.sh --diff      # Pull and show what changed
./uninstall.sh          # Clean removal (Claude Code itself is not touched)
```

---

## File layout

```
~/.claude/
  commands/                  Slash commands (122 .md files)
  settings.json              MCP server config (GitHub, Fetch)

~/.ai-bu-hub/                Source repos (17 tools cloned from GitHub)
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

## Contributing

Open an issue or submit a PR. To add a new tool, add its repo name to the `ALL_REPOS` array in `setup.sh`.

## License

MIT
