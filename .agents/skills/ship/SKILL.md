---
name: ship
description: Have the AI branch, commit, push, and create or update a pull request in the current repository. Use when the user says ship, asks to prepare a branch or commit, or wants help following the repo branch and PR workflow without pushing to the base branch.
---

# Ship Workflow

Use this skill when the user asks the AI to ship work.

## Contents

- [At A Glance](#at-a-glance)
- [Trigger Rules](#trigger-rules)
- [What This Is Not](#what-this-is-not)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Naming And Text](#naming-and-text)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Inspect the current branch, status, and actual diff.
2. Validate the touched area.
3. Use the current topic branch, or create a policy-compliant branch from the
   base branch when currently on it.
4. Stage only intended changes, commit with a policy-compliant message, then
   push.
5. Create or update the pull request and report the branch, commit, PR, and
   validation result.

## Trigger Rules

- Only start this workflow when the user's current message explicitly asks to
  ship, create a branch/commit/PR, or otherwise gives a clear go signal for the
  full ship workflow.
- Do not infer shipping approval from the fact that changes were just made,
  validation passed, a prior turn discussed shipping, or the work appears ready.
- If the user asks for edits, review, validation, or policy changes without a
  current-turn ship request, make the changes only and wait for an explicit
  ship/go confirmation before committing, pushing, or opening/updating a PR.

## What This Is Not

- Not a land workflow for merging pull requests or deleting topic branches.
- Not approval to commit unrelated local changes.
- Not permission to push directly to the base branch unless the user
  explicitly asks.
- Not permission to commit, push, or open/update a pull request after ordinary
  edits unless the user explicitly asks to ship in the current turn.
- Not a replacement for validation; run the smallest relevant checks before
  committing.

## Prerequisites

- Read `context/policies/approval-policy.md`,
  `context/policies/branch-policy.md`,
  `context/policies/commit-policy.md`,
  `context/policies/verification-policy.md`, and
  `context/policies/writing-guidelines.md`. Use the target repo's copy of each
  when it exists; otherwise use the bundled copy at
  `${CLAUDE_PLUGIN_ROOT}/context/policies/<file>`.
- Read the target repo's config file — `.orchraft.jsonc`, else
  `.orchraft.json` — when one exists, per `context/policies/config-policy.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/policies/config-policy.md`). A missing file
  is the normal case and means the documented defaults apply.
- Check `git status --short --branch` before changing branch or commit state.
- Confirm there are intended changes to ship.
- Identify untracked files and include only the ones that belong to this work.
- If already on a topic branch, assume the user wants to ship additional
  work on that branch unless they explicitly ask for a different branch.
- Inspect the full intended change set before naming anything: current branch,
  `git status`, unstaged diff, staged diff, and relevant untracked files.
- Generate the branch name, commit message, and pull request text from that
  complete inspected change set, not from memory or the ticket title alone.

## Default Path

1. Inspect branch state and working tree.
2. Validate the touched area per `context/policies/verification-policy.md`.
   When the config file sets `validate`, run that command rather than
   discovering one from the repository; it is the answer the repo already
   gave, so there is nothing left to infer. Everything else in
   `verification-policy.md` still applies to it — a failure is a stop, and
   the command that ran is reported as written.
3. Resolve the base branch first: `baseBranch` from the config file when set,
   otherwise the repository's default branch. Do not assume `main` — a
   repository on `master` or `develop` does not use it. If on the base
   branch, create a policy-compliant branch from it; if already on a topic
   branch, keep using it. Before creating or renaming any branch,
   count the words after `/` (excluding an Optional Ticket Key segment, if
   used) against `context/policies/branch-policy.md`'s limit and check the
   allowed characters — verify the generated name against the policy text
   itself, not just against the rule from memory, before running `git
   checkout -b` or a rename. A name that fails this check gets fixed before
   it's used, not caught later by `roast`.
4. Stage only the intended changes.
5. Write a commit title using `<type>(<scope>): <summary>`.
6. Add a commit body only when the title doesn't fully explain the change,
   written as free-form prose with no headings, per
   `context/policies/commit-policy.md`.
7. Let local git hooks run normally during commit. If hooks auto-fix files,
   review the resulting diff, stage only intended hook changes, and commit
   again.
8. Confirm the commit succeeded and no intended hook changes remain unstaged.
9. Push the topic branch.
10. Create or update the branch pull request through the GitHub MCP connector
   when it is available in the session. Use `gh` only after the MCP path has
   been tried and is unavailable or blocked.
11. If the PR has open review threads from a prior `roast` pass and this
    diff fixes the finding one flags, resolve that specific thread via
    `pull_request_review_write` (method `resolve_thread`) once the user gives
    the current-turn go-ahead per `context/policies/approval-policy.md`.
    Match each resolution to the finding it actually fixes; do not resolve
    threads wholesale or resolve one whose finding this diff doesn't address.
    A finding posted as an "outside diff range" or general PR comment (common
    from CodeRabbit and similar bots, since GitHub only allows threads on
    lines inside a diff hunk) has no review thread to resolve at all — say so
    plainly instead of treating it as resolved just because the diff fixes it.
12. If a review thread's finding — from `roast`, CodeRabbit, or a human
    reviewer — is being declined rather than fixed (a false positive, a
    deliberate tradeoff, out of scope for this PR), do not resolve it
    silently and do not leave it hanging with no response either. Draft a
    short, technical reply stating the concrete reason it won't be fixed,
    and once the user gives the current-turn go-ahead per
    `context/policies/approval-policy.md`, post it via
    `add_reply_to_pull_request_comment`. If that MCP path is unavailable,
    fall back to `gh api --method POST
    "repos/$owner/$repo/pulls/$number/comments" -f "body=$reply" -F
    "in_reply_to=$parent_review_comment_id"` — quoted shell variables, not
    bare angle-bracket placeholders, since an unquoted multiline reply can
    be parsed as redirection or split into multiple arguments. Never `gh
    pr comment`, which creates a top-level PR comment instead of a
    review-thread reply, so `reckoning` would never find it. This exact
    `gh api` form matches GitHub's documented review-comment-reply
    behavior but hasn't been exercised live in this repo; confirm the
    response actually carries a valid `id`/`html_url` the first time this
    fallback path fires, the same way `roast`'s own `gh` fallback
    validates its result, rather than trusting the command because it
    reads correctly. A reply is not a resolution: leave the thread
    unresolved unless the user separately asks to resolve it too. End the
    reply's visible text with a blank line and the hidden marker
    `<!-- orchraft:declined -->` so `reckoning` can find it later; the
    marker is metadata for that skill, not part of the stated reason
    itself.

## Naming And Text

- Always inspect the whole set of changes the user wants shipped before
  choosing the branch name, commit title/body, PR title, or PR body.
- Branch: follow `context/policies/branch-policy.md` exactly:
  `<type>/<short-kebab-description>`, using the same conventional type as the
  dominant change where possible.
- Commit title: follow `context/policies/commit-policy.md` exactly:
  `<type>(<scope>): <summary>`.
- Commit body: follow `context/policies/commit-policy.md` exactly: optional,
  free-form prose with no headings, describing only the staged diff.
- Pull request title: follow `context/policies/writing-guidelines.md`. Omit
  commit scope unless the user explicitly asks for it.
- Pull request body: follow `context/policies/writing-guidelines.md`. Describe
  the whole branch, not just the final commit. If the repository provides a PR
  template or PR body checks, follow that format first. Do not invent checklist
  items, screenshots, reviewers, or follow-up work.

## Guardrails

- Never commit or push directly to the base branch unless the user
  explicitly asks.
- Do not stop after push until the PR step is complete or clearly blocked.
- If the branch name would violate policy, stop and fix the branch name instead of improvising.
- Do not create a second topic branch from an existing topic branch unless
  the user explicitly asks to branch off or retarget the work.
- If branch creation fails with a git refs collision such as an existing
  `docs` ref blocking `docs/...`, diagnose the local and remote refs with the
  correct git commands before changing the branch name. Retry with approval
  when the failure may be permission or sandbox related. Do not switch to a
  less accurate type or unrelated branch name just to bypass the error.
- Never resolve a review thread whose finding this diff doesn't actually fix,
  and never resolve one without the user's current-turn go-ahead.
- Never post a decline reply to a review thread without the user's
  current-turn go-ahead, and never resolve a thread just because a decline
  reply was posted to it — a reply and a resolution are separate actions,
  each needing its own go-ahead.

## Stop Conditions

- Stop before commit, push, or PR mutation if the user has not explicitly asked
  to ship in the current turn.
- Stop if there are no changes to ship.
- Stop if the only available branch would be the base branch and the user did
  not explicitly allow committing to it.
- Stop if intended and unrelated changes cannot be separated safely.
- Stop if validation for the touched area fails, unless the user explicitly
  asks to ship despite the failure.
- Stop if local git hooks fail, abort the commit, or leave unexpected changes.
- Stop if branch, commit, or pull request text would violate the policy files.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line success
  phrase in the orc voice, speaking as the Raid Captain from
  `context/personality.md` (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with the
  plain result instead.
- Report the branch name.
- Report the commit title.
- Report the pull request URL or say why PR creation/update was blocked.
- Report validation that ran, or why validation could not run.
- Report which review threads, if any, were resolved and which finding each
  one fixed, and which threads, if any, got a decline reply and why.
- If shipping stops or fails, skip the shipping phrase and state the blocker
  plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Successful ship:

```text
🚢 Grah! War party launched. PR #123 holds the beach for review, chief. ✨

Branch: `fix/login-null-token`
Commit: `fix(auth): guard null login token`
PR: https://github.com/example/repo/pull/123
Validation: `<project validation command>`
```

Successful ship with docs only:

```text
🚢 Battle scrolls packed for the march. The docs PR has taken the field.

Branch: `docs/land-workflow`
Commit: `docs(agents): clarify land workflow`
PR: https://github.com/example/repo/pull/124
Validation: reviewed markdown changes
```

Successful ship on existing branch:

```text
🚢 Reinforcements sent to the same front. PR #124 holds the new line.

Branch: `docs/land-workflow`
Commit: `docs(agents): document land trigger rules`
PR: https://github.com/example/repo/pull/124
Validation: reviewed markdown changes
```

Blocked ship:

```text
⚠️ Shipping is blocked: validation failed in `<project validation command>`.

No commit or push was performed.
```
