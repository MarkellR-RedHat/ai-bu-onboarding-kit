# AI BU Hub - Complete Command Reference

Every slash command across all 17 tools, organized by workflow. 100+ commands at your fingertips.

---

## "I want to..." Quick Lookup

| I want to... | Command |
|--------------|---------|
| Start my morning with a summary | `/briefing` |
| See what needs my attention right now | `/risk-radar` |
| Understand a message someone sent me | `/read-the-room` |
| Clean up a rough email or Slack message | `/polish` |
| Make a message shorter | `/shorten` |
| Deliver bad news professionally | `/bad-news` |
| Say no to a request nicely | `/decline-politely` |
| Write an escalation email | `/escalation` |
| Write a follow-up nudge | `/follow-up` |
| Change the tone of a message | `/tone-shift` |
| Check writing against Red Hat style | `/style-check` |
| Auto-fix style issues | `/style-fix` |
| Get my weekly status report | `/status-report` |
| Prepare an executive summary | `/executive-summary` |
| Structure messy meeting notes | `/meeting-notes` |
| Extract action items from notes | `/action-items` |
| Prepare for an upcoming meeting | `/pre-brief` |
| See if a meeting should be canceled | `/meeting-cancel` |
| Write a conference talk proposal | `/cfp` |
| Build a slide deck outline | `/slides` |
| Summarize a long document fast | `/speedread` |
| Decide if a doc is worth reading | `/speedread-verdict` |
| See what competitors shipped | `/whats-new` |
| Track upstream project changes | `/upstream` |
| Summarize what my team shipped | `/shipped` |
| Turn a PR into a blog post | `/blog-from-pr` |
| Get feedback from a specific persona | `/review-as` |
| Figure out what to work on next | `/what-next` |
| Understand an unfamiliar repo quickly | `/tldr-repo` |
| Write documentation | `/write-docs` |

---

## Daily Workflow

### Morning Briefing (ai-bu-daily-briefing)

| Command | Description |
|---------|-------------|
| `/briefing` | Daily GitHub activity summary with priorities |
| `/standup` | Quick standup-format update from recent activity |
| `/catch-me-up` | Catch up on what happened while you were out |
| `/risk-radar` | Surface risks, blockers, and items needing attention |
| `/team-pulse` | Team activity summary across repos |
| `/week-ahead` | Preview of what is coming up this week |
| `/weekly-digest` | End-of-week summary of all activity |

### Status Reports (ai-bu-status-report)

| Command | Description |
|---------|-------------|
| `/status-report` | Weekly status report from Git history and PRs |
| `/executive-summary` | High-level summary for leadership |
| `/team-report` | Aggregate status across multiple team members |
| `/okr-update` | Progress update mapped to OKRs |
| `/quarterly-review` | Quarterly accomplishments and metrics |
| `/status-trends` | Track trends across multiple status periods |

---

## Communication

### Message Polishing (ai-bu-message-polisher)

| Command | Description |
|---------|-------------|
| `/polish` | Clean up any rough draft while keeping your voice |
| `/shorten` | Cut message length in half, keep the meaning |
| `/tone-shift` | Rewrite in a different tone (formal, casual, urgent) |
| `/bad-news` | Deliver bad news using the BIFF framework |
| `/decline-politely` | Say no without burning bridges |
| `/escalation` | Format a proper escalation email |
| `/follow-up` | Write a professional follow-up nudge |
| `/read-the-room` | Decode what a message is really saying |
| `/cross-cultural` | Adapt a message for a different culture or region |
| `/thread-summary` | Summarize a long Slack or email thread |

### Style and Tone (ai-bu-style-checker)

| Command | Description |
|---------|-------------|
| `/style-check` | Check content against Red Hat writing guidelines |
| `/style-fix` | Auto-fix style issues in a document |
| `/style-score` | Get a numeric style score with breakdown |
| `/style-batch` | Check an entire directory of files |
| `/style-diff` | Check only changed lines in a git diff |
| `/style-compare` | Compare two document versions for style improvement |
| `/style-learn` | Teach the checker about project-specific exceptions |
| `/tone-check` | Analyze where content falls on the tone spectrum |

---

## Meetings

### Meeting Notes (ai-bu-meeting-notes)

| Command | Description |
|---------|-------------|
| `/meeting-notes` | Structure raw notes into decisions and action items |
| `/action-items` | Extract every action item from notes |
| `/decision-log` | Pull out all decisions made |
| `/agenda` | Create a structured meeting agenda |
| `/pre-brief` | Prepare for a meeting by analyzing the context |
| `/standup-notes` | Format async standup updates |
| `/raci` | Build a RACI matrix from meeting notes |
| `/follow-up-check` | Compare current notes against previous action items |
| `/meeting-email` | Draft a follow-up email from meeting notes |
| `/meeting-cancel` | Assess whether a meeting should be an email instead |

---

## Content Creation

### Conference Proposals (ai-bu-cfp-generator)

| Command | Description |
|---------|-------------|
| `/cfp` | Draft a full conference talk proposal |
| `/cfp-review` | Review and improve an existing proposal |
| `/cfp-reviewer` | Simulate a CFP reviewer scoring your proposal |
| `/cfp-variants` | Generate multiple angles for the same talk |
| `/cfp-ab-test` | Create A/B variants of a proposal title and abstract |
| `/cfp-from-blog` | Turn a blog post into a talk proposal |
| `/lightning-talk` | Draft a 5-minute lightning talk proposal |
| `/talk-to-blog` | Convert talk content into a blog post |
| `/workshop-proposal` | Draft a workshop or tutorial proposal |

### Presentations (ai-bu-slide-outliner)

| Command | Description |
|---------|-------------|
| `/slides` | Build a complete presentation outline |
| `/slide-from-doc` | Distill a long document into a slide deck |
| `/slide-story` | Build narrative-driven slides using SCR framework |
| `/slide-hooks` | Generate compelling opening hooks for a talk |
| `/slide-review` | Get brutally honest feedback on a presentation |
| `/slide-pacing` | Analyze and fix presentation pacing |
| `/slide-notes` | Generate presenter cue card notes |
| `/slide-visuals` | Art direction for slide visuals |
| `/slide-to-marp` | Convert an outline to Marp markdown format |

### Writing (ai-bu-claude-commands)

| Command | Description |
|---------|-------------|
| `/blog-from-pr` | Turn a pull request into a blog post |
| `/draft-announcement` | Write a product or project announcement |
| `/write-docs` | Write documentation that engineers actually read |
| `/release-notes` | Write release notes for downstream maintainers |
| `/changelog` | Generate a CHANGELOG.md entry |

---

## Intelligence and Tracking

### Competitive Watch (ai-bu-competitive-watch)

| Command | Description |
|---------|-------------|
| `/whats-new` | See what competitors just released |
| `/landscape` | Map the competitive landscape for a domain |
| `/battlecard` | Generate a sales battlecard against a competitor |
| `/feature-matrix` | Build a feature comparison matrix |
| `/swot` | SWOT analysis for a product or project |
| `/positioning` | Analyze competitive positioning |
| `/diff-release` | Compare two releases of a competitor product |
| `/trend-report` | Identify trends across the competitive landscape |
| `/win-loss` | Analyze win/loss patterns |

### Upstream Tracking (ai-bu-upstream-tracker)

| Command | Description |
|---------|-------------|
| `/upstream` | Track changes in upstream projects |
| `/upstream-weekly` | Weekly upstream activity digest |
| `/upstream-breaking` | Flag breaking changes in upstream |
| `/upstream-opportunity` | Find contribution opportunities upstream |
| `/upstream-contributor` | Analyze upstream contributor activity |

### Shipped Digest (ai-bu-shipped-digest)

| Command | Description |
|---------|-------------|
| `/shipped` | Summarize what shipped recently in a repo |
| `/shipped-email` | Format shipped items as a team email |
| `/shipped-slack` | Format shipped items for Slack |
| `/shipped-release-notes` | Generate release notes from merged PRs |
| `/shipped-metrics` | Analyze repo activity metrics |
| `/shipped-compare` | Compare what shipped across multiple repos |

---

## Research and Review

### Speed Reader (ai-bu-speed-reader)

| Command | Description |
|---------|-------------|
| `/speedread` | Full summary of a long document or web page |
| `/speedread-verdict` | Quick "read it or skip it" assessment |
| `/speedread-bullets` | The fastest possible summary, just the signal |
| `/speedread-extract` | Pull every concrete fact and number |
| `/speedread-eli5` | Explain so a non-technical person understands |
| `/speedread-annotate` | Annotated version with inline commentary |
| `/speedread-compare` | Compare two documents side by side |
| `/speedread-questions` | Generate the questions a peer reviewer would ask |
| `/speedread-chain` | Map intellectual lineage and related work |

### Persona Reviews (ai-bu-review-as-persona)

| Command | Description |
|---------|-------------|
| `/review-as` | Get feedback from any persona you describe |
| `/review-for-audience` | Simulate a custom audience reading your content |
| `/review-multi` | Run multiple personas on the same content |
| `/red-team` | Adversarial review to find weaknesses |
| `/debate` | Stage a two-persona debate about your content |
| `/persona-builder` | Build a detailed persona for repeated use |
| `/empathy-map` | Create a UX empathy map for a persona |
| `/rewrite-for` | Rewrite content as a specific persona would write it |

---

## Engineering Tools

### Code and Repo (ai-bu-claude-commands)

| Command | Description |
|---------|-------------|
| `/tldr-repo` | Understand an unfamiliar repo in 30 seconds |
| `/what-next` | Figure out the highest-impact thing to work on |
| `/retro` | Facilitate a sprint or project retrospective |
| `/demo-prep` | Prepare for a live demo |
| `/explain-for-customer` | Explain a technical issue for a customer audience |
| `/summarize-thread` | Summarize a GitHub issue or discussion thread |
| `/competitive-snapshot` | Quick competitive intelligence on a topic |

### Project Templates (ai-bu-claude-md-templates)

| Command | Description |
|---------|-------------|
| `/compose-template` | Create a new CLAUDE.md template for your project |
| `/suggest-template` | Get a suggested CLAUDE.md based on your repo |

---

## Power User Patterns

### Morning routine
```bash
claude /briefing            # What happened overnight
claude /risk-radar          # Anything on fire?
```

### Before sending any message
```bash
claude /polish "your draft"
claude /style-check "the polished version"
```

### Friday status update pipeline
```bash
claude /status-report       # Generate from Git history
claude /polish "..."        # Tighten the language
claude /style-check "..."   # Final quality pass
```

### Meeting workflow
```bash
claude /pre-brief           # Prepare before the meeting
# ... attend the meeting ...
claude /meeting-notes       # Structure your raw notes
claude /action-items        # Extract every action item
claude /meeting-email       # Draft the follow-up email
```

### Content creation pipeline
```bash
claude /cfp                 # Draft the proposal
claude /cfp-reviewer        # Simulate a reviewer scoring it
claude /cfp-variants        # Try different angles
```

### Presentation workflow
```bash
claude /slides              # Build the outline
claude /slide-hooks         # Nail the opening
claude /slide-pacing        # Check the timing
claude /slide-review        # Get honest feedback
claude /slide-to-marp       # Convert to Marp for rendering
```

### Research workflow
```bash
claude /speedread doc.pdf   # Get the summary
claude /speedread-extract   # Pull the facts
claude /speedread-verdict   # Worth the full read?
```

### Competitive intelligence
```bash
claude /whats-new           # What just shipped
claude /landscape           # Map the space
claude /battlecard          # Prep for a sales call
```

---

## Management Commands

| Command | Description |
|---------|-------------|
| `./setup.sh` | Install everything |
| `./setup.sh --minimal` | Install top 5 tools only |
| `./setup.sh --pick` | Interactive selection menu |
| `./setup.sh --dry-run` | Preview what would be installed |
| `./update.sh` | Pull latest versions of all tools |
| `./update.sh --diff` | Update and show what changed |
| `./verify.sh` | Full health check dashboard |
| `./verify.sh --quiet` | Summary-only health check |
| `./uninstall.sh` | Remove all Hub tools cleanly |

---

## Where Things Live

| Path | Contents |
|------|----------|
| `~/.claude/commands/` | Installed slash command files (100+) |
| `~/.ai-bu-hub/` | Cloned Hub repo sources (17 repos) |
| `~/.claude/settings.json` | MCP server configuration |
| `~/.ai-bu-hub/.backups/` | Backup snapshots from updates |

---

*Keep this open in a tab until the commands become muscle memory.*
