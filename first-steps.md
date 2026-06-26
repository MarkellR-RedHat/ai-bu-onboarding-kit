# First Steps with the AI BU Hub

You ran `setup.sh` and everything is installed. Now what?

This is an interactive walkthrough. Each step builds on the last, so follow them in order. By the end, you will have used the core commands and know how they fit together.

## Before you start

Open a terminal and make sure Claude Code is working:

```bash
claude --version
```

**Expected output:**
```
claude v1.x.x
```

If you get "command not found," Claude Code is not installed. See the [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) to set it up.

You can run Claude Code from any directory. The slash commands you installed are available globally.

---

## Step 1: Get your daily briefing

The `/briefing` command pulls your GitHub activity and gives you a summary of what happened overnight, what PRs need your attention, and what is coming up.

```bash
claude /briefing
```

**Expected output:**

You should see a structured summary with sections like:
- PRs you need to review
- PRs you are waiting on
- Recent issues and mentions
- Suggested priorities for the day

**When to use it:** Every morning, or whenever you want a quick status check on your GitHub activity.

> If you see "no GitHub activity found," make sure `gh auth status` shows you are authenticated.

---

## Step 2: Polish a rough message

The `/polish` command takes a rough draft and cleans it up. It fixes grammar, tightens the language, and keeps your voice.

Try this example:

```bash
claude /polish "hey team, wanted to let u know that the thing we talked about last week is done, the PR is up and i think we should merge it soon before the other changes land"
```

**Expected output:**

A cleaned-up version of your message. Something like:

> Team, the work we discussed last week is complete. The PR is up and ready for review. I recommend merging soon before the upcoming changes land.

Compare the two versions. The meaning stays the same, but the language is tighter and more professional.

**When to use it:** Before sending emails, Slack messages, or PR descriptions. Paste in your rough draft and get back something clean.

---

## Step 3: Check your writing style

The `/style-check` command reviews a document against Red Hat writing guidelines. It catches jargon, passive voice, and inconsistencies.

Create a quick test file first:

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

A list of style issues found in the document. You should see flags for:
- "utilize" (prefer "use")
- "leverage" (overused jargon)
- "in order to" (wordy, just say "to")
- "basically" (filler word)
- Passive voice ("was designed to be used")

**When to use it:** Before publishing blog posts, documentation, or any external-facing content.

---

## Step 4: Generate a status report

The `/status-report` command builds a weekly status report from your recent Git commits, merged PRs, and project activity.

Navigate to a project repo and run:

```bash
cd ~/your-project-repo  # use a real repo with recent commits
claude /status-report
```

**Expected output:**

A structured status report with sections like:
- What you shipped this week
- PRs merged
- Work in progress
- Blockers (if any)

If the report looks thin, make sure you are running it inside a Git repo with recent commits.

**When to use it:** Friday afternoon, or whenever your manager asks what you have been working on.

---

## Step 5: Prepare meeting notes

The `/meeting-notes` command helps you structure raw meeting notes into a clean format with action items, decisions, and follow-ups.

```bash
claude /meeting-notes
```

Claude will ask you to paste in your raw notes. Try pasting something like:

```
talked about q3 planning. maria said we need to ship the auth service
by end of july. john will handle the migration. need to check with
platform team about the new API limits. decided to skip the v2 redesign
for now. next meeting is thursday.
```

**Expected output:**

Structured notes with:
- **Decisions:** Skip v2 redesign for now
- **Action items:** John handles migration; check with platform team on API limits
- **Deadlines:** Auth service ships by end of July
- **Next meeting:** Thursday

**When to use it:** Right after a meeting, while the details are still fresh.

---

## Step 6: Review as a persona

The `/review-as-persona` command lets you get feedback on your writing from a specific perspective, like a customer, a senior engineer, or a product manager.

```bash
claude /review-as-persona
```

Claude will ask you for the persona and the content to review. Try asking for a "skeptical senior engineer" review of a technical blog post or README.

**Expected output:**

Feedback written from the perspective you chose, highlighting concerns that persona would have. A senior engineer might flag missing error handling, vague architecture claims, or untested assumptions.

**When to use it:** When you want a second opinion on how something reads to a particular audience.

---

## More commands to explore

These are available too, depending on which repos were set up:

| Command | What it does |
|---------|-------------|
| `/cfp-generator` | Draft a conference talk proposal |
| `/slide-outliner` | Outline a slide deck from a topic |
| `/competitive-watch` | Get a summary of competitor activity |
| `/upstream-tracker` | Track upstream project changes |
| `/shipped-digest` | Summarize what shipped recently |
| `/speed-reader` | Summarize a long document quickly |

---

## 5-Minute Challenge

Put what you learned together. Use three commands in sequence to solve a real task:

**Scenario:** You need to send your manager a polished end-of-week update.

1. **Generate the raw material:**
   ```bash
   claude /status-report
   ```
   Copy the output.

2. **Polish the language:**
   ```bash
   claude /polish "<paste your status report here>"
   ```
   This tightens the wording and makes it ready to send.

3. **Style-check before sending:**
   ```bash
   claude /style-check "<paste the polished version>"
   ```
   Catch any remaining jargon or passive voice.

You just went from raw Git history to a send-ready status update in under 5 minutes. That is the AI BU Hub workflow: chain commands together to get things done faster.

---

## Tips

**Run commands from your project directory.** Some commands (like `/status-report`) use your Git history, so run them from inside a repo.

**Pipe in content.** Many commands accept input from stdin or as arguments. Check each command's help for details.

**Update regularly.** Run `./update.sh` to pull the latest versions of all commands from the Hub repos.

## Something broken?

Run the verification script:

```bash
./verify.sh
```

This checks that all prerequisites are installed, repos are cloned, and commands are in place. If something is missing, run `setup.sh` again.
