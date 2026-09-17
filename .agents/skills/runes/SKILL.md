---
name: runes
description: Have the AI summarize where the current branch's work actually stands — its PR, checks, and unresolved review findings — grounded in live git/GitHub state, not memory. Use when the user says runes, asks to resume, "where were we", "what's the status", or wants to pick a branch back up without re-explaining it.
---

# Runes Workflow

Use this skill when the user wants to pick up existing work without
re-explaining it, and wants the status grounded in the actual current state
of the branch and its pull request, not a recollection from earlier in the
conversation.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Summary Format](#summary-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Identify the branch to report on (current branch by default, or one the
   user names).
2. Read its live state fresh: local worktree, its pull request (if any),
   check/mergeability status, and the latest `roast` review's standing
   findings.
3. Summarize where it actually stands and name the next logical step,
   without taking it.
4. Stop. Never commit, push, or touch a PR/issue as part of this skill.

## What This Is Not

- Not `yap`: yap explains a specific named thing in depth; runes gives a
  status snapshot of a branch's whole lifecycle position.
- Not `roast`: it doesn't produce new findings — it reports the standing
  result of the last `roast` pass already on the PR.
- Not an orchestrator: naming the next logical step is not running it. Any
  actual next step (`ship`, `roast`, `land`) still needs the user to ask for
  it in that turn, per `context/policies/approval-policy.md`.
- Not a substitute for checking approval-policy.md before a mutation — this
  skill never mutates, so it carries no approval of its own.

## Trigger Rules

- Run when the user explicitly asks to runes, resume, "where were we"/
  "what's the status"/"catch me up", or wants to pick a branch back up
  without restating its history.
- If no branch is current and none is named, ask which branch to summarize
  instead of guessing.
- Do not run automatically at the start of every session; only when the user
  asks, or a project-local hook explicitly invokes it (see
  `context/policies/approval-policy.md` — a hook surfacing status is not the
  same as it mutating anything).

## Prerequisites

- Determine the target branch: the current branch by default, or the one the
  user names.
- Look up whether the target branch has a pull request via the GitHub MCP
  connector (falling back to `gh` when unavailable or blocked), by branch
  name — not by whether the local branch has an upstream configured, since
  a PR can exist on GitHub even when the local branch has no upstream
  tracking ref set. Classify the result explicitly: none, draft, open,
  closed, or merged. Only a confirmed `none` justifies naming `ship` as the
  next step.
- If a PR exists in any state, fetch its current state fresh in this turn:
  head SHA, mergeable state, check runs/status, and its most recent
  reviews — including `roast`'s delta-tracking marker
  (`<!-- roast:review head=<sha> -->`) from its Comment Format, to
  find the latest `roast` pass's standing findings and whether the PR head
  has moved past it.
- If the target branch is the currently checked-out branch, check
  `git status --short` for local uncommitted changes, since those affect
  what `ship` would actually do next. If the target branch isn't currently
  checked out, its own uncommitted-changes state can't be read without
  switching to it (this skill doesn't check out branches) — say that
  plainly instead of attributing the current worktree's changes to it.

## Default Path

1. Resolve the target branch (see Prerequisites).
2. If the PR state is `none`, report that plainly — the next step is
   `ship`, not a status summary of a PR that doesn't exist.
3. If the PR state is `draft`, report it as a draft explicitly — the next
   step is finishing and marking it ready, not `ship` (which would try to
   open a duplicate) or `land`.
4. If the PR state is `closed` or `merged`, report that plainly — the
   branch is stale relative to it; the next step is likely starting fresh
   or cleaning up the branch, not shipping more commits onto it.
5. If the PR state is `open`, gather: PR number/URL, check/mergeability
   status, the latest `roast` review's finding counts by severity, and
   whether any of its threads are still unresolved.
6. Note whether the PR head has moved since that `roast` review's marker
   commit — if so, say the standing findings may be stale rather than
   presenting them as current.
7. Note local uncommitted changes per the Prerequisites' checked-out-branch
   caveat.
8. Name the next logical step (e.g. "roast hasn't run yet", "2 findings
   still unresolved", "clean and land-ready") without taking it.

## Summary Format

Keep it to what's actually known — don't pad a thin status with filler.

- **Branch** — name and whether it has an upstream.
- **PR** — number, URL, state (none/draft/open/closed/merged),
  mergeable/check status.
- **Reviews** — the latest `roast` pass's finding counts by severity, and
  whether that pass is still current for the PR's head commit. Omit unless
  the PR state is `open`.
- **Local changes** — any uncommitted work, only when the target branch is
  the currently checked-out branch (see Prerequisites).
- **Next step** — the logical next action, named but not taken.

## Guardrails

- Never commit, push, or touch a PR/issue as part of this skill.
- Never present a `roast` review's findings as current once the PR head has
  moved past that review's marker commit — say they may be stale instead.
- Never invent a status for something that couldn't be checked (e.g. no
  GitHub access) — say what's unverifiable instead of guessing.
- Never attribute the currently checked-out worktree's uncommitted changes
  to a target branch that isn't actually checked out.
- Never recommend `ship` as the next step without a confirmed `none` PR
  state — a missed PR lookup is not the same as no PR existing.

## Stop Conditions

- Stop and ask which branch to summarize if there's no current branch and
  none was named.
- Stop if the GitHub MCP connector and `gh` are both unavailable and the
  branch has a PR to check — report the local-only state (branch, worktree)
  and say PR/review status couldn't be verified.
- Stop after presenting the summary; do not proceed into `ship`, `roast`, or
  `land` without the user separately asking for it.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Rune-Reader from
  `context/personality.md` (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain summary instead.
- Present the summary per [Summary Format](#summary-format).
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

PR with open findings:

```text
📖 Hrrm. The runes say PR #142 still carries one open crack. Picking up there. ✨

Branch: `fix/login-crash` (PR #142, open)
PR: mergeable, checks green
Reviews: last roast pass (current) found 1 important, 0 critical
Next step: fix the finding, then ship and resolve its thread.
```

Clean and land-ready:

```text
📖 Hah! The board reads clean. PR #145 stands ready for the gate.

Branch: `docs/land-workflow` (PR #145, open)
PR: mergeable, checks green
Reviews: last roast pass (current) found 0 issues
Next step: land whenever you give the word.
```

No PR yet:

```text
📖 Hrrm. This branch hasn't taken the field yet.

Branch: `feat/offline-cache` (no PR)
Local changes: 3 files modified, not yet committed
Next step: ship it to open the PR.
```

Blocked, no branch to check:

```text
❓ Chief, which branch should I read the runes on?
```
