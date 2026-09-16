---
name: ship
description: Have the AI branch, commit, push, and create or update a pull request in the current repository. Use when the user says ship, asks to prepare a branch or commit, or wants help following the repo branch and PR workflow without pushing to main.
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
3. Use the current non-`main` branch, or create a policy-compliant branch from
   `main` when currently on `main`.
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
- Not permission to push directly to `main` unless the user explicitly asks.
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
- Check `git status --short --branch` before changing branch or commit state.
- Confirm there are intended changes to ship.
- Identify untracked files and include only the ones that belong to this work.
- If already on a non-`main` branch, assume the user wants to ship additional
  work on that branch unless they explicitly ask for a different branch.
- Inspect the full intended change set before naming anything: current branch,
  `git status`, unstaged diff, staged diff, and relevant untracked files.
- Generate the branch name, commit message, and pull request text from that
  complete inspected change set, not from memory or the ticket title alone.

## Default Path

1. Inspect branch state and working tree.
2. Validate the touched area per `context/policies/verification-policy.md`.
3. If on `main`, create a policy-compliant branch from `main`; if already on a
   non-`main` branch, keep using it.
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

- Never commit or push directly to `main` unless the user explicitly asks.
- Do not stop after push until the PR step is complete or clearly blocked.
- If the branch name would violate policy, stop and fix the branch name instead of improvising.
- Do not create a second topic branch from an existing non-`main` branch unless
  the user explicitly asks to branch off or retarget the work.
- If branch creation fails with a git refs collision such as an existing
  `docs` ref blocking `docs/...`, diagnose the local and remote refs with the
  correct git commands before changing the branch name. Retry with approval
  when the failure may be permission or sandbox related. Do not switch to a
  less accurate type or unrelated branch name just to bypass the error.

## Stop Conditions

- Stop before commit, push, or PR mutation if the user has not explicitly asked
  to ship in the current turn.
- Stop if there are no changes to ship.
- Stop if the only available branch would be `main` and the user did not
  explicitly allow committing to `main`.
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
