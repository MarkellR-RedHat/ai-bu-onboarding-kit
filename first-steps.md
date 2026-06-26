# First Steps with the AI BU Hub

You ran `setup.sh` and everything is installed. Now what?

This walkthrough covers the commands you will use most often, with real examples.

## Before you start

Open a terminal and make sure Claude Code is working:

```bash
claude --version
```

You can run Claude Code from any directory. The slash commands you installed are available globally.

## 1. Get your daily briefing

The `/briefing` command pulls your GitHub activity and gives you a summary of what happened overnight, what PRs need your attention, and what is coming up.

```
claude /briefing
```

This is a great way to start your day. It checks your notifications, open PRs, and recent issues.

**When to use it:** Every morning, or whenever you want a quick status check on your GitHub activity.

## 2. Polish a rough message

The `/polish` command takes a rough draft and cleans it up. It fixes grammar, tightens the language, and keeps your voice.

```
claude /polish "hey team, wanted to let u know that the thing we talked about last week is done, the PR is up and i think we should merge it soon before the other changes land"
```

**When to use it:** Before sending emails, Slack messages, or PR descriptions. Paste in your rough draft and get back something clean.

## 3. Check your writing style

The `/style-check` command reviews a document against Red Hat writing guidelines. It catches jargon, passive voice, and inconsistencies.

```
claude /style-check blog-post.md
```

**When to use it:** Before publishing blog posts, documentation, or any external-facing content.

## 4. Generate a status report

The `/status-report` command builds a weekly status report from your recent Git commits, merged PRs, and project activity.

```
claude /status-report
```

**When to use it:** Friday afternoon, or whenever your manager asks what you have been working on.

## 5. Prepare meeting notes

The `/meeting-notes` command helps you structure raw meeting notes into a clean format with action items, decisions, and follow-ups.

```
claude /meeting-notes
```

**When to use it:** Right after a meeting, while the details are still fresh.

## 6. Review as a persona

The `/review-as-persona` command lets you get feedback on your writing from a specific perspective, like a customer, a senior engineer, or a product manager.

```
claude /review-as-persona
```

**When to use it:** When you want a second opinion on how something reads to a particular audience.

## More commands to explore

These are available too, depending on which repos were set up:

- `/cfp-generator` - Draft a conference talk proposal
- `/slide-outliner` - Outline a slide deck from a topic
- `/competitive-watch` - Get a summary of competitor activity
- `/upstream-tracker` - Track upstream project changes
- `/shipped-digest` - Summarize what shipped recently
- `/speed-reader` - Summarize a long document quickly

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
