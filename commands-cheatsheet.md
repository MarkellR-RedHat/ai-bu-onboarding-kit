# AI BU Hub - Commands Cheatsheet

Quick reference for all installed slash commands. Run any of these inside Claude Code.

---

## Daily Workflow

| Command | What it does | Example |
|---------|-------------|---------|
| `/briefing` | Daily GitHub activity summary | `claude /briefing` |
| `/status-report` | Weekly status report from Git history | `claude /status-report` |
| `/meeting-notes` | Structure raw notes into action items | `claude /meeting-notes` |

## Writing and Communication

| Command | What it does | Example |
|---------|-------------|---------|
| `/polish` | Clean up a rough draft | `claude /polish "rough text here"` |
| `/style-check` | Check against Red Hat writing style | `claude /style-check doc.md` |
| `/review-as-persona` | Get feedback from a specific perspective | `claude /review-as-persona` |

## Content Creation

| Command | What it does | Example |
|---------|-------------|---------|
| `/cfp-generator` | Draft a conference talk proposal | `claude /cfp-generator` |
| `/slide-outliner` | Outline a slide deck from a topic | `claude /slide-outliner` |
| `/speed-reader` | Summarize a long document | `claude /speed-reader long-doc.md` |

## Tracking and Intelligence

| Command | What it does | Example |
|---------|-------------|---------|
| `/competitive-watch` | Summary of competitor activity | `claude /competitive-watch` |
| `/upstream-tracker` | Track upstream project changes | `claude /upstream-tracker` |
| `/shipped-digest` | Summarize what shipped recently | `claude /shipped-digest` |

---

## Common Patterns

**Morning routine:**
```bash
claude /briefing
```

**Before sending an email:**
```bash
claude /polish "your rough draft"
```

**Friday status update:**
```bash
claude /status-report
```

**Before publishing a blog post:**
```bash
claude /style-check post.md
```

**After a meeting:**
```bash
claude /meeting-notes
```

**Chaining commands (status report to polished email):**
```bash
claude /status-report        # generate the raw report
claude /polish "<output>"    # tighten the language
claude /style-check "<output>"  # final quality check
```

---

## Management Commands

| Command | What it does |
|---------|-------------|
| `./setup.sh` | Install everything |
| `./setup.sh --minimal` | Install top 5 commands only |
| `./setup.sh --dry-run` | Preview what would be installed |
| `./update.sh` | Pull latest versions |
| `./verify.sh` | Check installation health |
| `./uninstall.sh` | Remove all Hub tools |

---

## Where Things Live

| Path | Contents |
|------|----------|
| `~/.claude/commands/` | Installed slash command files |
| `~/.ai-bu-hub/` | Cloned Hub repo sources |
| `~/.claude/settings.json` | MCP server configuration |

---

*Print this page and keep it next to your monitor until the commands become muscle memory.*
