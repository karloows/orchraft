---
name: review
description: Have the AI review the current pull request's diff against this repo's own policies and commit history, then post the findings as a PR review with inline comments and a summary. Use when the user says review, asks for a PR review, or wants CodeRabbit-style automated review after shipping.
---

# Review Workflow

Use this skill when the user asks the AI to review a pull request, or right
after `ship` opens/updates one and the user asks for a review pass on it.

## Contents

- [At A Glance](#at-a-glance)
- [Requirements](#requirements)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Sources Of Truth](#sources-of-truth)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Severity Guide](#severity-guide)
- [Comment Format](#comment-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)

## At A Glance

1. Confirm there is an open pull request for the current branch.
2. Read the actual PR diff, not just the working tree.
3. Check the diff against this repo's own policies, not external style rules.
4. Report findings by severity, then post them as a single PR review: one
   comment anchored to each finding's diff line, plus one summary.
5. Stop. Do not push fixes unless the user explicitly asks.

## Requirements

What the end user needs in place before this skill can work at all:

- A GitHub MCP connector configured for this session, authenticated as an
  account with comment/review write access to the repository (not just read).
  Without write access, findings can still be produced but never posted.
- `gh` installed and authenticated as a fallback path, for when the MCP
  connector is unavailable mid-session.
- The branch must already have an open, non-draft pull request — run `ship`
  first if it doesn't. This skill reviews an existing PR; it does not create
  one.
- `context/policies/` present in the repo for the policy-compliance checks to
  mean anything; if this repo doesn't have them, that check is skipped rather
  than invented (see [Sources Of Truth](#sources-of-truth)).

## What This Is Not

- Not a fix workflow. It reports; it does not edit code.
- Not a replacement for `ship`'s commit-time validation — this runs against
  the PR as a whole, after it exists.
- Not permission to approve, merge, or request changes on the PR unless the
  user explicitly asks; posting a comment is not a review decision.
- Not a search for an external "coderabbit ruleset." This repo's own
  `context/policies/` files and code are the standard, not a hosted or
  invented rulebook.

## Trigger Rules

- Run when the user explicitly asks to review, review the PR, or check the
  branch the way an automated reviewer would.
- Run immediately after `ship` when the user asks `ship` to include a review,
  or says so as a standing preference (e.g. "always review after you ship").
- Do not run automatically on every `ship` unless the user has said so; `ship`
  and `review` are separate skills with separate trigger rules.

## Sources Of Truth

Rely on what already exists in this repo instead of an external knowledge
base:

- `context/policies/branch-policy.md`, `context/policies/commit-policy.md`,
  and `context/policies/writing-guidelines.md` for naming, commit, and PR-text
  compliance.
- The PR's own commit history for whether Conventional Commits was actually
  followed, not just the final diff.
- Any project-local architecture, design-system, or lint/CI config already in
  the repo (e.g. `CLAUDE.md`, `AGENTS.md`, linter configs, CI workflow files).
  Read what the repo already enforces; do not assume rules it does not have.
- The PR description and linked issue/task, if any, as the benchmark for scope
  — read it before judging whether something is missing or out of scope.

If the repo has none of the above beyond generic conventions, review against
correctness, the conventions already visible in the surrounding code, and the
policies above only.

## Prerequisites

- Call `get_me` first to confirm the connected GitHub identity and its access
  before doing anything else — this predicts permission failures (fork PRs,
  read-only tokens) instead of discovering them after building the review.
- Confirm the current branch is non-`main` and has an open, non-draft pull
  request; use the GitHub MCP connector to fetch it, falling back to `gh`
  only if the MCP path is unavailable or blocked. If no PR exists yet, that
  most likely means `ship` hasn't run on this branch — say so instead of a
  generic "no PR found."
- Fetch the full PR diff and commit list from GitHub, not a local `git diff`
  guess — the PR may include commits from other pushes.
- Record the PR's current head SHA, base SHA (or an equivalent diff-identity
  hash), and state (open) before reviewing, and re-check all of them
  immediately before posting — if the head or base changed (a force-push, a
  new commit, or a retargeted base branch), re-fetch the diff and recompute
  findings instead of posting against a stale one; if the PR was merged or
  closed while the review was being built, stop and report that instead of
  posting to a PR that's no longer open.
- Check for an existing pending review on the PR (`pull_request_review_write`
  method `get`/list, or the equivalent read). Only discard it if it's
  confirmed to belong to the connected account (from `get_me`) — a pending
  review owned by someone else is their in-progress work, not a stale
  leftover, and must be left untouched. If ownership can't be established,
  stop instead of guessing (see Stop Conditions).
- Check for this skill's prior review(s) on the PR. If one exists, review
  only the code delta since that review's commit and note which earlier
  findings still stand, were fixed, or no longer apply — do not re-post
  unchanged findings as if they were new. Scope and policy compliance (PR
  title, description, branch name) are PR-level, not commit-level — re-check
  those against their current state every time, even on a delta review.
- Read the sources listed above before judging anything.

## Default Path

1. Fetch the PR (title, body, commits, diff) through the GitHub MCP connector.
2. Compare the diff against the PR description/linked task — flag scope gaps
   in either direction (planned-but-missing, or shipped-but-unplanned).
3. Check policy compliance: branch name, each commit title/body, and the PR
   title/body against `context/policies/`.
4. Check the code itself: correctness, error handling, edge cases, and
   consistency with existing patterns in the touched files. Always scan for
   hardcoded secrets, tokens, keys, or credentials in the diff and flag any
   as Critical — this check runs regardless of what else is found. Skip
   generated, vendored, or lockfile diffs (e.g. `*.lock`, `dist/`,
   `node_modules/`, checked-in build output) — no human authored those lines.
   If the diff is too large to read in one pass, review file-by-file,
   prioritizing logic and security-sensitive files over docs/config, rather
   than silently truncating or skipping the rest.
5. Rank findings by severity (see below). Group findings that land on the
   same file/line into a single inline comment instead of stacking multiple
   comments on one line.
6. Post the findings as one PR review through the GitHub MCP connector:
   - `pull_request_review_write` with method `create` to open a pending
     review.
   - `add_comment_to_pending_review` once per remaining file/line, capped at
     20 inline comments. Beyond the cap, list the rest as bullets in the
     summary body instead of continuing to post individual comments — a wall
     of inline comments is noise, not signal.
   - `pull_request_review_write` with method `submit_pending` (event
     `COMMENT`, never `REQUEST_CHANGES`/`APPROVE` unless the user asks) using
     the summary report as the review body.
   A finding can only anchor to a line inside the diff's hunks — GitHub
   rejects comments on unchanged lines. Route any finding without a valid
   diff-line anchor (e.g. "this untouched file should have been updated too")
   into the summary body instead of dropping it or erroring.
   Fall back to `gh pr comment` with the full report as one issue comment only
   if the MCP review-write path is itself unavailable.
7. Confirm `submit_pending` (or the `gh` fallback) actually returned a review
   ID/URL before declaring success — a call that doesn't error is not proof
   it posted; verify the response, don't assume it.
8. Report the same findings to the user in the chat response.

## Severity Guide

- **Critical** — breaks behavior, violates a required policy (e.g. commit
  format, direct push to `main`), or the PR is missing something the linked
  task explicitly asked for.
- **Important** — will compound if left in (inconsistent pattern, missing
  edge case a real user hits, drift from an established convention).
- **Minor** — cosmetic or non-blocking (naming nit, optional polish).

## Comment Format

Inline comment (one per line-specific finding, via
`add_comment_to_pending_review`):

```
[SEVERITY] <one-line finding> — <why it matters / what to do>
```

Review-body summary (the `submit_pending` body, covers everything that isn't
line-specific plus a rollup):

```
## Review — <PR title>

### Scope
[PASS / ISSUES] — planned vs. shipped

### Policy compliance
[PASS / ISSUES] — branch, commit, PR text vs. context/policies/

### Code review
[PASS / ISSUES] — correctness, edge cases, consistency (see inline comments)

### Summary
[N] issue(s): [critical count] critical, [important count] important,
[minor count] minor.
```

Write both in the tone required by
`context/policies/writing-guidelines.md`: concise, technical, no emojis, no
marketing language. Emoji handoff phrasing below applies to the chat response
to the user only, never to anything posted on the PR.

## Guardrails

- Never edit files, commit, or push as part of this skill.
- Never approve, merge, or request-changes the PR unless the user explicitly
  asks for that decision.
- Post one review per pass (one pending review, submitted once); do not open
  multiple pending reviews or submit partial reviews one comment at a time.
- Do not invent policies this repo does not have. If something looks wrong
  but no policy or visible convention covers it, flag it as a judgment call,
  not a violation.

## Stop Conditions

- Stop if there is no open, non-draft pull request for the current branch —
  say to run `ship` first rather than just "no PR found."
- Stop if the GitHub MCP connector and `gh` are both unavailable — report the
  findings in chat only and say the PR comment could not be posted.
- Stop if the connected account lacks permission to comment (e.g. a
  fork-originated PR) — report this as a permissions issue, not as MCP being
  down, and share the findings in chat instead.
- Stop before posting if the user asked for a private/local review only.
- Stop and re-fetch instead of posting if the PR head SHA changed since the
  diff was fetched; do not post a review against a diff that no longer
  matches the PR.
- Stop if the PR was merged or closed after the review was fetched but before
  it was posted — report the findings in chat and do not post to a PR that's
  no longer open.
- Stop if a leftover pending review cannot be discarded cleanly, or its
  ownership can't be confirmed as the connected account's — report it so the
  user can resolve it on GitHub instead of guessing.
- If `submit_pending` fails after inline comments were already added, do not
  exit silently — report that a pending review was left partially built on
  the PR, with the findings in chat, so the user knows it needs manual
  submission or discarding on GitHub.

## Handoff

- Only use the success phrasing below once the post is confirmed (a returned
  review ID/URL), not just because the API call didn't error.
- Use a warm, lively one-line review phrase when the workflow succeeds, such
  as `🔍 Review's in. The rabbit hole has been fully explored. ✨`
- Report the PR number and the finding counts by severity.
- If there were zero findings, say so plainly and skip listing severities.
- If posting stops or fails, skip the lively phrasing and state the blocker
  plainly, then share the findings in chat instead.

## Response Examples

Clean review, no findings:

```text
✅ Clean pass. Nothing to flag on this one.

PR #123: 0 issues found.
```

Review with findings:

```text
🔍 Review's in. The rabbit hole has been fully explored. ✨

PR #124: 3 issues found — 1 critical, 1 important, 1 minor.
Posted as a PR review with inline comments plus a summary.
```

Blocked review:

```text
⚠️ Review is blocked: no open pull request on this branch yet.

Run `ship` first, then review. No comment or review was posted.
```
