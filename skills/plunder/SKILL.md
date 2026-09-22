---
name: plunder
description: Have the AI report this repo's real shipping signal — PRs opened, review findings `roast` caught and whether they were fixed or declined, and time-to-land — grounded in live git/GitHub history, not an invented score. Use when the user says plunder, asks for shipping stats, wants a retrospective on PRs or reviews, or wants to know how the clan's actually been doing.
---

# Plunder Workflow

Use this skill when the user wants a real, repo-wide look at what shipping
has actually looked like — not one branch's status, and not a synthetic
benchmark score, but counts pulled from this repo's own PR and review
history.

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

1. Enumerate every pull request in the target repo, across every state.
2. Count findings `roast` caught per PR by parsing its own posted scoreboard
   tables, and classify each finding's fate — fixed, declined and standing,
   or declined and later settled — from the same review-thread signal
   `reckoning` already reads.
3. Compute time-to-land (`merged_at - created_at`) for every merged PR and
   report the real median across them.
4. Report the totals. Never invent a number nothing in the data supports.
5. Stop. Never touch a PR/issue — this skill only reads.

## What This Is Not

- Not `runes`: `runes` reports one branch's live status; Plunder
  reports repo-wide historical totals.
- Not `reckoning`: `reckoning` lists standing declined-finding debt only;
  Plunder reports the fuller picture — every finding's fate, PR
  counts, and time-to-land — and does not stop at what's still owed.
- Not a benchmark score. There is no invented "hours saved" or "lines
  reviewed" number here — every figure is a real count or a real elapsed
  time pulled from this repo's own history.
- Not permission to act on anything it finds — a slow time-to-land or a high
  decline rate is information, not an instruction to change how the clan
  works.

## Trigger Rules

- Run when the user explicitly asks for a plunder count/tally, shipping
  stats, a retrospective on PRs or reviews, or how many findings `roast` has
  caught.
- Do not run automatically; every other status-reporting skill here
  (`runes`, `reckoning`, `watchtower`) is invoke-on-purpose, and this one is
  no different.

## Requirements

- A GitHub MCP connector configured for this session with at least read
  access to pull requests, their review comments, and their reviews, or `gh`
  installed and authenticated as a fallback. Without either, stop and say
  the count can't run rather than reporting a partial or empty result as
  complete.

## Prerequisites

- Confirm which repo to count: the current one by default, or one the user
  names — the same default `reckoning` uses.
- Enumerate every pull request in that repo the same way `reckoning` does:
  `list_pull_requests` with `state: all`, paginating through every page, or
  `gh api --paginate "repos/$owner/$repo/pulls?state=all" --jq '.[] |
  {number, html_url, state, created_at, merged_at}'` when MCP is
  unavailable. `merged_at` is what distinguishes "merged" from "closed
  without merging," since GitHub reports both as `state: "closed"`. This
  count is the PR population — every PR in the repo, not only ones a marker
  identifies as `ship`-opened, since no such marker exists; say this
  assumption plainly in the report rather than silently narrowing the count.
- For each PR, fetch its reviews (`pull_request_read` method `get_reviews`),
  paginating through every page at the requested `perPage` size until a page
  returns fewer reviews than that size — a PR with more reviews than one
  page holds still needs every `roast` pass counted, not just the first
  page's. Across every page, find each review whose body ends in `roast`'s
  delta-tracking marker (`<!-- roast:review head=<sha> -->`, from
  `skills/roast/SKILL.md`'s Comment Format) and parse that review's
  scoreboard table — the
  `| 🚨 Critical | ⚠️ Important | 💡 Minor | 🤔 Judgment calls |` row `roast`
  always posts — for that pass's finding counts. Sum across every `roast`
  pass on the PR; a PR reviewed twice contributes both passes' counts, not
  just the latest.
- For each PR, fetch its review threads via `pull_request_read` method
  `get_review_comments`, the same call `reckoning` uses, which returns each
  thread's `is_resolved` status and full comment list. To attribute a
  thread to a specific `roast` review (rather than a human reviewer's own
  comment), the review-comment shape needs the owning review's id or body,
  which this MCP method's documented output doesn't confirm it carries; if
  it doesn't, fall back to a `gh api graphql` query for the PR's
  `reviewThreads(first: 100, after: $cursor)` requesting each thread's
  `comments(first: 1) { nodes { pullRequestReview { body } } }` and match
  threads whose first comment's owning review body carries the `roast`
  marker. Loop pagination the same way `reckoning`'s own GraphQL fallback
  does, for both threads and comments, until each `hasNextPage` is false.
  Verify this attribution once against a real PR with a known `roast`
  review before trusting it at repo scale — this exact lookup hasn't been
  exercised in this repo before, unlike the rest of this skill's data
  sources.
- Within each `roast`-attributed thread, classify its fate the same way
  `reckoning` reads the `<!-- orchraft:declined -->` marker `ship` writes
  (`skills/ship/SKILL.md` Default Path step 12): resolved with no decline
  reply → **fixed**; a decline reply present and the thread still
  unresolved → **declined, standing**; a decline reply present and the
  thread later resolved → **declined, settled**; unresolved with no decline
  reply → **open, unaddressed**. A finding with no diff-line anchor (posted
  in `roast`'s own "Unanchored findings" summary section, not as a thread)
  has no thread to classify at all — count it in the scoreboard total but
  report it separately as **unclassifiable (unanchored)**, rather than
  guessing. A thread that does have a diff-line anchor but whose owning
  review couldn't be confirmed as `roast`'s (the attribution lookup itself
  failed or returned ambiguous results) is a different case — report it
  separately as **unclassifiable (attribution-unverified)**, never folded
  into the unanchored bucket, since the two have different causes and a
  future fix targets them differently.
- For time-to-land, use only PRs with a non-null `merged_at`. Compute each
  one's `merged_at - created_at` and the median across all of them.

## Default Path

1. Resolve the target repo (see Prerequisites).
2. Enumerate every PR and record its state, `created_at`, and `merged_at`.
3. For each PR, sum its `roast`-posted scoreboard counts across every pass.
4. For each PR, classify every `roast`-attributed thread's fate per
   Prerequisites, tallying unclassifiable (unanchored) and unclassifiable
   (attribution-unverified) findings as separate totals.
5. Compute time-to-land per merged PR and the median across them.
6. Report the totals per [Summary Format](#summary-format), or that the
   repo has no PR/review history yet.

## Summary Format

Keep it to what was actually counted — don't pad a thin result with filler,
and don't round a real count into a marketing-sounding figure.

- **Repo** — name, and how many PRs were counted (open, merged, and
  closed-without-merging, mutually exclusive).
- **Findings caught** — total `roast` scoreboard count by severity
  (Critical/Important/Minor/Judgment calls), across every pass on every PR.
- **Findings by fate** — counts for fixed, declined-and-standing,
  declined-and-settled, open-and-unaddressed, unclassifiable (unanchored),
  and unclassifiable (attribution-unverified), reported as separate totals
  rather than merged into one bucket, since the two have different causes.
- **Time-to-land** — the median across merged PRs, plus the count it's
  computed from. Omit if no PR in the repo has merged yet.
- **Assumption noted** — that the PR count treats every PR in the repo as
  the population, since no marker distinguishes a `ship`-opened PR from a
  manually opened one.

## Guardrails

- Never touch a PR or issue, resolve a thread, or post a reply as part of
  this skill — it only reads.
- Never invent a figure the data doesn't support — no benchmark-style
  "hours saved" or synthetic score. Every number is a real count or a real
  elapsed time.
- Never attribute a review thread to `roast` without verifying which review
  it actually belongs to; when that attribution can't be confirmed, report
  the thread as unclassifiable (attribution-unverified) rather than
  guessing its fate.
- Never claim a "fixed" or "declined" count includes unanchored or
  attribution-unverified findings — neither has a classified thread, and
  both are reported as their own separate totals, never merged with each
  other or with a classified fate.

## Stop Conditions

- Stop and say so if neither the GitHub MCP connector nor `gh` is
  available — don't report a partial or guessed count as complete.
- Stop and say so if any individual required fetch fails partway
  through — a paginated PR/review-thread listing, a per-PR `get_reviews`
  page, or a GraphQL attribution query alike. Name which operation failed
  and report the result as incomplete, never a partial count presented as
  the full total.
- Stop after presenting the summary; do not proceed into `ship`, `roast`,
  `land`, or any mutation without the user separately asking for it.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Quartermaster from
  `context/personality.md` (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain summary instead.
- Present the summary per [Summary Format](#summary-format).
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Real history to report (illustrative — actual output names real numbers):

```text
💰 Hrrm. The chest is full: N raids counted, most came home clean. ✨

Repo: <owner>/<repo> (N PRs counted: X open, Y merged, Z closed without
merging)
Findings caught: A critical, B important, C minor, D judgment calls
By fate: E fixed, F declined (standing), G declined (settled),
H open/unaddressed, I unclassifiable (unanchored), K unclassifiable
(attribution-unverified)
Time-to-land: median J hours across Y merged PRs
Note: counts every PR in the repo as the population — no marker
distinguishes a ship-opened PR from a manually opened one.
```

No history yet:

```text
💰 Hah! The chest is empty — no pull requests to count yet.

Repo: <owner>/<repo> (0 PRs)
```

Blocked, no GitHub access:

```text
⚠️ Plunder is blocked: neither the GitHub MCP connector nor `gh` is
available. No count was performed.
```
