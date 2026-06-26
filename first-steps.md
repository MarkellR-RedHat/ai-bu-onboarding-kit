# Your First 10 Minutes with AI BU Hub

You ran `setup.sh` and everything is installed. This walkthrough builds your confidence step by step, starting with the most impressive commands and working toward power-user workflows. Each step takes about 2 minutes.

## Before you start

Open a terminal and confirm Claude Code is working:

```bash
claude --version
```

You should see something like `claude v1.x.x`. If you get "command not found," visit the [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) to install it first.

Slash commands are global. You can run them from any directory.

---

## Step 1: Read the room on a message (1 min)

Start with something that delivers instant value. The `/read-the-room` command analyzes a message someone sent you and decodes what is really going on underneath the surface.

```bash
claude /read-the-room
```

Paste in a Slack message, email, or PR comment that felt "off" and let Claude break it down for you.

**What you should see:**

- The literal ask vs. the real ask
- Emotional tone and urgency level
- Suggested response strategies
- Things the sender might not be saying directly

**When to use it:** Before responding to a message that feels loaded, political, or unclear.

---

## Step 2: Get your daily briefing (2 min)

The `/briefing` command pulls your GitHub activity and gives you a structured morning summary.

```bash
claude /briefing
```

**What you should see:**

- PRs that need your review
- PRs you are waiting on
- Recent issues and mentions
- Suggested priorities for the day

If you see "no GitHub activity found," make sure `gh auth status` shows you are authenticated.

**When to use it:** Every morning, first thing. It replaces 10 minutes of GitHub browsing.

---

## Step 3: Polish a rough message (1 min)

The `/polish` command takes your rough draft and makes it land better. No corporate fluff, just tighter and clearer.

```bash
claude /polish "hey team, wanted to let u know that the thing we talked about last week is done, the PR is up and i think we should merge it soon before the other changes land"
```

**What you should see:**

A cleaned-up version like:

> Team, the work we discussed last week is complete. The PR is up and ready for review. I recommend we merge before the upcoming changes land.

Same meaning, tighter language, more professional. Your voice stays intact.

**When to use it:** Before sending emails, Slack messages, or PR descriptions.

---

## Step 4: Check your writing style (2 min)

The `/style-check` command reviews content against Red Hat writing guidelines. It catches the stuff you stop noticing after a while.

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

**What you should see:**

Flags for:
- "utilize" (prefer "use")
- "leverage" (overused jargon)
- "in order to" (wordy, just say "to")
- "basically" (filler word)
- Passive voice ("was designed to be used")

Each finding includes the line, the issue, and a concrete fix.

**When to use it:** Before publishing blog posts, docs, or anything external-facing.

---

## Step 5: Generate a status report (2 min)

The `/status-report` command builds a weekly update from your Git commits and merged PRs. No more Friday afternoon scrambling.

Navigate to a real repo with recent commits:

```bash
cd ~/your-project-repo
claude /status-report
```

**What you should see:**

- What you shipped this week
- PRs merged with summaries
- Work in progress
- Blockers (if any)

If the report looks thin, make sure you are in a repo with recent activity.

**When to use it:** Friday afternoon, or when someone asks "what have you been working on?"

---

## Step 6: Speed-read a long document (2 min)

The `/speedread` command summarizes long documents so you can decide whether to read the full thing.

```bash
claude /speedread https://some-long-technical-doc-url
```

Or point it at a local file:

```bash
claude /speedread ~/Downloads/that-30-page-whitepaper.pdf
```

**What you should see:**

- One-paragraph summary
- Key claims and findings
- Important numbers and facts
- Whether it is worth reading the whole thing

**Power tip:** Use `/speedread-verdict` for a quick "read it or skip it" answer, or `/speedread-extract` to pull every concrete fact.

---

## Putting it all together: The 5-minute challenge

Chain three commands to solve a real task. Scenario: you need to send your manager a polished end-of-week update.

**1. Generate the raw material:**
```bash
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

You just went from raw Git history to a send-ready status update in under 5 minutes. That is the AI BU Hub workflow: chain commands together to move faster.

---

## What to explore next

Now that you have the basics, here are the commands worth exploring by category:

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
