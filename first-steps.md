# First 10 Minutes with AI BU Hub

Setup is done. Six things to try, each one useful on its own. Work top to bottom or jump to whatever looks relevant.

Slash commands are global. You can run them from any directory.

---

## Step 1: Decode a message (30 seconds)

`/read-the-room` takes any message and breaks down what is actually going on underneath the words.

```bash
claude /read-the-room
```

Paste in a Slack message, email, or PR comment that felt "off" and let Claude analyze it.

**Expected output:**

```
The literal ask: "Can we sync on the timeline?"

The real ask: They think the project is behind schedule and want
to understand why without directly saying so.

Tone: Professional but concerned. Urgency level: Medium-high.

Suggested response: Acknowledge the concern directly. Lead with
what is on track before addressing delays. Propose a specific
date rather than a vague "let's chat."
```

**When to use it:** Before responding to anything that feels loaded, political, or unclear.

---

## Step 2: Polish a rough message (1 minute)

`/polish` tightens your writing without adding corporate fluff. Your voice stays intact.

```bash
claude /polish "hey team, wanted to let u know that the thing we talked about last week is done, the PR is up and i think we should merge it soon before the other changes land"
```

**Expected output:**

```
Team, the work we discussed last week is complete. The PR is up
and ready for review. I recommend we merge before the upcoming
changes land.
```

Same meaning, tighter language, more professional.

**When to use it:** Before sending emails, Slack messages, or PR descriptions.

---

## Step 3: Get your daily briefing (2 minutes)

`/briefing` pulls your GitHub activity into a structured morning summary.

```bash
claude /briefing
```

**Expected output:**

```
MORNING BRIEFING - June 26, 2026

PRs needing your review (3):
  #412  Add retry logic to inference endpoint    @teammate
  #408  Update model serving docs                @teammate
  #405  Fix memory leak in batch processor       @teammate

Your open PRs (1):
  #410  Refactor config loader  -  2 approvals, ready to merge

Recent mentions (2):
  Issue #89  -  tagged for input on scaling strategy
  PR #407    -  comment asking about test coverage

Suggested priorities:
  1. Merge #410 (fully approved)
  2. Review #405 (bug fix, time-sensitive)
  3. Respond to #89 (team waiting on your input)
```

If you see "no GitHub activity found," make sure `gh auth status` shows you are authenticated.

**When to use it:** Every morning, first thing.

---

## Step 4: Check your writing style (2 minutes)

`/style-check` reviews content against Red Hat writing guidelines.

Create a quick test file:

```bash
cat > /tmp/test-post.md << 'EOF'
# Getting Started with Our Platform

In order to utilize the functionality of our solution, users should
leverage the built-in capabilities. The platform was designed to be
used by developers who want to maximize their productivity.

Basically, it's really easy to get started. Just click the button
and the system will do the rest of the work for you.
EOF
```

Now check it:

```bash
claude /style-check /tmp/test-post.md
```

**Expected output:**

```
STYLE CHECK RESULTS - /tmp/test-post.md

Line 3: "In order to" -> "To" (wordy)
Line 3: "utilize" -> "use" (plain language)
Line 4: "leverage" -> "use" or "take advantage of" (overused jargon)
Line 4: "was designed to be used" -> passive voice, rewrite as active
Line 7: "Basically" -> remove (filler word)
Line 7: "really easy" -> "straightforward" (vague intensifier)

Score: 4/10
6 issues found. Run /style-fix to auto-correct.
```

**When to use it:** Before publishing blog posts, docs, or anything external-facing. Run `/style-fix` to auto-correct.

---

## Step 5: Generate a status report (2 minutes)

`/status-report` builds a weekly update from your Git commits and merged PRs.

Navigate to a repo with recent commits:

```bash
cd ~/your-project-repo
claude /status-report
```

**Expected output:**

```
STATUS REPORT - Week of June 22, 2026

Shipped:
  - Refactored config loader for multi-model support (#410)
  - Fixed flaky integration test in CI pipeline (#403)
  - Added health check endpoint to serving layer (#398)

In progress:
  - Scaling benchmarks for llm-d inference (branch: scale-benchmarks)
  - Documentation update for new API versioning

Reviewed:
  - 4 PRs reviewed across 2 repos

Blockers:
  - None this week
```

If the report looks thin, make sure you are in a repo with recent activity.

**When to use it:** Friday afternoon, or whenever someone asks "what have you been working on?"

---

## Step 6: Summarize a long document (1 minute)

`/speedread` summarizes long documents so you can decide whether to read the whole thing.

```bash
claude /speedread https://some-long-technical-doc-url
```

Or point it at a local file:

```bash
claude /speedread ~/Downloads/that-30-page-whitepaper.pdf
```

**Expected output:**

```
SUMMARY (30-page document, ~45 min read)

One-paragraph summary:
The paper proposes a new approach to distributed inference that
reduces latency by 40% through speculative execution. Results
are benchmarked against vLLM and TensorRT-LLM on A100 clusters.

Key findings:
  - 40% latency reduction at p99 for batch sizes under 32
  - Memory overhead increases by 15% (acceptable tradeoff)
  - Does not outperform existing solutions above batch size 64

Worth reading? YES, if you work on inference optimization.
Skip sections 4-6 (implementation details) unless you plan to
contribute upstream.
```

Also try `/speedread-verdict` for a quick "read or skip" answer, or `/speedread-extract` to pull every fact and number.

---

## Chaining commands

The real power shows up when you chain tools together. Each output feeds the next input.

### Chain 1: Status report to send-ready email

Three commands to go from raw Git history to a polished, style-checked status update.

**1. Generate the raw material:**
```bash
cd ~/your-project-repo
claude /status-report
```
Copy the output.

**2. Polish the language:**
```bash
claude /polish "<paste your status report>"
```

**3. Final quality check:**
```bash
claude /style-check "<paste the polished version>"
```

### Chain 2: Conference talk from a PR

You shipped something interesting. Turn it into a conference talk proposal.

**1. Turn the PR into a blog post:**
```bash
claude /blog-from-pr https://github.com/org/repo/pull/123
```

**2. Convert the blog post into a CFP:**
```bash
claude /cfp-from-blog "<paste the blog post>"
```

**3. Stress-test the proposal:**
```bash
claude /cfp-reviewer "<paste the proposal>"
```

**4. Try different angles:**
```bash
claude /cfp-variants "<paste the proposal>"
```

### Chain 3: Meeting prep to follow-up

Full meeting lifecycle in four commands.

**1. Prep before the meeting:**
```bash
claude /pre-brief "Agenda: discuss Q3 roadmap, review scaling benchmarks, assign ownership"
```

**2. After the meeting, structure your raw notes:**
```bash
claude /meeting-notes "<paste raw notes>"
```

**3. Extract action items:**
```bash
claude /action-items "<paste structured notes>"
```

**4. Draft the follow-up email:**
```bash
claude /meeting-email "<paste notes and action items>"
```

### Chain 4: Competitive intelligence briefing

Prepare for a customer call or strategy meeting.

**1. See what competitors shipped recently:**
```bash
claude /whats-new "vLLM, TensorRT-LLM, SGLang"
```

**2. Map the landscape:**
```bash
claude /landscape "LLM inference serving"
```

**3. Generate a battlecard:**
```bash
claude /battlecard "vLLM vs our product"
```

### Chain 5: Document triage to team summary

You have a stack of documents to review. Get through them fast.

**1. Quick verdict on each doc:**
```bash
claude /speedread-verdict ~/Downloads/whitepaper-1.pdf
claude /speedread-verdict ~/Downloads/whitepaper-2.pdf
```

**2. Deep dive on the ones worth reading:**
```bash
claude /speedread ~/Downloads/whitepaper-1.pdf
```

**3. Pull hard facts and numbers:**
```bash
claude /speedread-extract ~/Downloads/whitepaper-1.pdf
```

**4. Share with the team, polished:**
```bash
claude /polish "<paste your summary of findings>"
```

---

## More commands by category

### Communication

| Command | What it does |
|---------|-------------|
| `/shorten` | Cut a message to half its length |
| `/tone-shift` | Rewrite in a different tone (formal, casual, urgent) |
| `/bad-news` | Deliver bad news using BIFF framework |
| `/decline-politely` | Say no without burning bridges |
| `/escalation` | Format an escalation email |

### Meetings

| Command | What it does |
|---------|-------------|
| `/meeting-notes` | Structure raw notes into decisions and action items |
| `/pre-brief` | Prep for a meeting from the agenda |
| `/action-items` | Extract action items from notes |
| `/meeting-cancel` | Decide if a meeting should be an email |

### Content

| Command | What it does |
|---------|-------------|
| `/cfp` | Draft a conference talk proposal |
| `/slides` | Build a presentation outline |
| `/blog-from-pr` | Turn a PR into a blog post |
| `/talk-to-blog` | Convert talk content into a blog post |

### Tracking

| Command | What it does |
|---------|-------------|
| `/whats-new` | What competitors just shipped |
| `/upstream` | Track upstream project changes |
| `/shipped` | What your team shipped recently |
| `/landscape` | Map the competitive landscape |

For the complete reference, see [commands-cheatsheet.md](commands-cheatsheet.md).

---

## Troubleshooting

**"No GitHub activity found" from `/briefing`:**
Check that `gh auth status` returns authenticated. If not, run `gh auth login`. If you do not have `gh` installed, `/briefing` cannot read your GitHub data.

**Commands not found after setup:**
Verify that `~/.claude/commands/` contains `.md` files. If the directory is empty, run `./setup.sh` again. If you are on Linux and your home directory is on an NFS mount, check that the mount is writable.

**Clone failures during setup:**
The script retries failed clones automatically. If repos keep failing, check your network connection and try `git ls-remote https://github.com/MarkellR-RedHat/ai-bu-claude-commands.git` to test connectivity. Behind a corporate proxy? Set `HTTPS_PROXY` before running setup.

**`/status-report` output is empty:**
Make sure you are inside a git repo with recent commits. The command reads your local Git history. If you are in a fresh clone with no commits from you, the report will be blank.

**MCP servers not working:**
Run `./verify.sh` to check MCP server health. Common fixes: ensure Node.js 18+ is installed, check `~/.claude/settings.json` for correct server entries, and verify that `npx` is on your PATH.

**Permission denied on `~/.claude/commands/`:**
Run `chmod u+w ~/.claude/commands/` and try again. On shared systems, check that another user has not locked the directory.

---

## Tips

**Run commands from your project directory.** Commands like `/status-report` and `/shipped` use your Git history, so run them from inside a repo.

**Many commands accept inline input.** You can pass text directly or let Claude prompt you for it.

**Update regularly.** Run `./update.sh` to pull the latest versions of all commands.

**Something broken?** Run `./verify.sh` to get a full health check with diagnostics and fix suggestions.
