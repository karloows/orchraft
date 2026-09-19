---
name: reckoning
description: Have the AI list every review finding that was consciously declined rather than fixed, across the whole repo's pull requests, grounded in live GitHub data. Use when the user says reckoning, asks what's been declined, wants a debt list, or wants to see deferred findings before a release.
---

# Reckoning Workflow

Use this skill when the user wants to see the repo's standing debt of
consciously declined review findings — not the current branch's status,
the whole repo's.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Requirements](#requirements)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Summary Format](#summary-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Search the repo's pull requests for review-comment replies carrying the
   `<!-- orchraft:declined -->` marker `ship` posts (see
   `.agents/skills/ship/SKILL.md` Default Path step 12).
2. For each one, report the PR, the file/line, the original finding, and the
   stated decline reason, and whether that PR is still open or already
   merged/closed.
3. Stop. Never touch a PR/issue, and never resolve or reply to anything —
   this skill only reads.

## What This Is Not

- Not `runes`: `runes` reports one branch's live status; `reckoning` reports
  standing decline debt across the whole repo's PR history.
- Not `roast`: it produces no new findings and posts nothing — it reads
  findings `roast` (or a human reviewer) already raised and that were
  already declined via `ship`.
- Not a backfill tool. Only replies carrying the marker are found; a decline
  reply posted before the marker existed won't show up, and this skill
  never guesses which unmarked replies might have been declines.
- Not permission to resolve, reply to, or otherwise act on anything it
  finds — reporting a debt is not authorization to settle it.

## Trigger Rules

- Run when the user explicitly asks for a reckoning, what's been declined,
  a debt list, deferred findings, or wants a pre-release check of standing
  debt.
- Do not run automatically; every other status-reporting skill here
  (`runes`, `watchtower`) is invoke-on-purpose, and this one is no
  different.

## Requirements

- A GitHub MCP connector configured for this session with at least read
  access to pull requests and their review comments, or `gh` installed and
  authenticated as a fallback. Without either, stop and say the search
  can't run rather than reporting an empty or partial list as complete.

## Prerequisites

- Confirm which repo to search: the current one by default, or one the user
  names.
- Search that repo's pull requests — open, closed, and merged, since debt
  survives a merge — for review-comment replies containing the
  `<!-- orchraft:declined -->` marker.
- For each match, read the comment thread it replies to for the original
  finding text, and confirm the thread's current resolved state (a debt
  someone later resolved manually on GitHub is settled, not standing).

## Default Path

1. Resolve the target repo (see Prerequisites).
2. Search for marked decline replies across all PR states.
3. For each one still on an unresolved thread, record: PR number/URL and
   state (open/closed/merged), file and line, the original finding
   (severity if stated), the decline reason, and who declined it.
4. Drop any match whose thread was later resolved — the marker means it was
   declined at the time, not that it must stay open forever; a human
   resolving it later is a legitimate settling of that debt.
5. Group by PR, most recently declined first.
6. Report the list, or that none exist.

## Summary Format

Keep it to what was actually found — don't pad an empty result with filler.

- **Repo** — name, and how many PRs were searched (open/closed/merged
  counts).
- **Standing debt** — one entry per unresolved declined finding: PR
  number/URL and state, file:line, the original finding, the decline
  reason.
- **None found** — say so plainly if the search turned up nothing, and
  distinguish that from "couldn't search" (see Requirements).

## Guardrails

- Never touch a PR or issue, resolve a thread, or post a reply as part of
  this skill — it only reads.
- Never report a resolved thread as standing debt just because it once
  carried the marker.
- Never invent a decline reason that isn't in the actual reply text.
- Never treat an unmarked reply as a declined finding, even if its prose
  reads like one — the marker is the only signal this skill trusts.

## Stop Conditions

- Stop and say so if neither the GitHub MCP connector nor `gh` is
  available — don't report a partial or guessed list as complete.
- Stop after presenting the summary; do not proceed into `ship`, `roast`,
  or any mutation without the user separately asking for it.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Reckoner from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain summary instead.
- Present the summary per [Summary Format](#summary-format).
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Standing debt found (illustrative — actual output names real PRs/files):

```text
🗂️ Hrrm. Two debts still stand on the books. ✨

Repo: <owner>/<repo> (N PRs searched: X open, Y merged)
- PR #<n> (<state>): `<path>:<line>` — <one-line finding summary>;
  declined because <the stated reason from the reply itself>.
- PR #<n> (<state>): `<path>:<line>` — <one-line finding summary>;
  declined because <the stated reason from the reply itself>.
```

Clean books:

```text
🗂️ Hah! The books read clean — nothing declined stands open.

Repo: <owner>/<repo> (N PRs searched: X open, Y merged)
```

Blocked, no GitHub access:

```text
⚠️ Reckoning is blocked: neither the GitHub MCP connector nor `gh` is
available. No search was performed.
```
