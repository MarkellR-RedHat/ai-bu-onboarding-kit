# Your First 10 Minutes with AI BU Hub

Setup is done. Everything is installed. This walkthrough is your product tour: six steps, each one building on the last, each one showing you something that saves real time. Start at the top and work your way down.

Slash commands are global. You can run them from any directory.

---

## Step 1: Decode a message (30 seconds)

This is the one that makes people say "whoa." The `/read-the-room` command takes any message someone sent you and breaks down what is actually going on underneath the words.

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

**When to use it:** Before responding to anything that feels loaded, political, or unclear. It takes 30 seconds and can save you from a 30-minute misunderstanding.

---

## Step 2: Polish a rough message (1 minute)

You have something to send but it reads like a first draft. The `/polish` command tightens your writing without adding corporate fluff. Your voice stays intact.

```bash
claude /polish "hey team, wanted to let u know that the thing we talked about last week is done, the PR is up and i think we should merge it soon before the other changes land"
```

**Expected output:**

```
Team, the work we discussed last week is complete. The PR is up
and ready for review. I recommend we merge before the upcoming
changes land.
```

Same meaning, tighter language, more professional. Try it on a real message you need to send today.

**When to use it:** Before sending emails, Slack messages, or PR descriptions. Especially when you are writing fast and want it to land well.

---

## Step 3: Get your daily briefing (2 minutes)

The `/briefing` command pulls your GitHub activity and gives you a structured morning summary. No more opening 15 tabs to figure out what needs your attention.

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

**When to use it:** Every morning, first thing. It replaces 10 minutes of GitHub tab-hopping.

---

## Step 4: Check your writing style (2 minutes)

The `/style-check` command reviews content against Red Hat writing guidelines. It catches the habits you stop noticing after a while.

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

Each finding includes the line, the issue, and a concrete fix.

**When to use it:** Before publishing blog posts, docs, or anything external-facing. Run `/style-fix` to let Claude auto-correct the issues.

---

## Step 5: Generate a status report (2 minutes)

The `/status-report` command builds a weekly update from your Git commits and merged PRs. No more Friday afternoon scrambling to remember what you did.

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

The `/speedread` command summarizes long documents so you can decide whether to commit the time to read the whole thing.

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

**Pro tip:** Use `/speedread-verdict` for a quick "read it or skip it" answer, or `/speedread-extract` to pull every concrete fact and number.

---

## The 5-minute challenge

Chain three commands to solve a real task. Scenario: you need to send your manager a polished end-of-week update.

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

You just went from raw Git history to a send-ready status update in under 5 minutes.

---

## What to explore next

Now that you have the basics, here are the commands worth trying by category:

### Communication power tools

| Command | What it does |
|---------|-------------|
| `/shorten` | Cut a message to half its length without losing meaning |
| `/tone-shift` | Rewrite a message in a different tone (formal, casual, urgent) |
| `/bad-news` | Deliver bad news using the BIFF framework |
| `/decline-politely` | Say no without burning bridges |
| `/escalation` | Format an escalation email properly |

### Meeting productivity

| Command | What it does |
|---------|-------------|
| `/meeting-notes` | Structure raw notes into decisions and action items |
| `/pre-brief` | Prepare for a meeting by analyzing the agenda |
| `/action-items` | Extract every action item from meeting notes |
| `/meeting-cancel` | Assess whether a meeting should just be an email |

### Content creation

| Command | What it does |
|---------|-------------|
| `/cfp` | Draft a conference talk proposal |
| `/slides` | Build a presentation outline |
| `/blog-from-pr` | Turn a PR into a blog post |
| `/talk-to-blog` | Convert talk content to a blog post |

### Intelligence and tracking

| Command | What it does |
|---------|-------------|
| `/whats-new` | See what competitors just shipped |
| `/upstream` | Track upstream project changes |
| `/shipped` | Summarize what your team shipped |
| `/landscape` | Map the competitive landscape |

For the complete reference, see [commands-cheatsheet.md](commands-cheatsheet.md).

---

## Tips

**Run commands from your project directory.** Commands like `/status-report` and `/shipped` use your Git history, so run them from inside a repo.

**Many commands accept inline input.** You can pass text directly or let Claude prompt you for it.

**Update regularly.** Run `./update.sh` to pull the latest versions of all commands.

**Something broken?** Run `./verify.sh` to get a full health check with diagnostics and fix suggestions.
