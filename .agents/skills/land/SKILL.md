---
name: land
description: Have the AI finish a topic branch end to end by merging its PR, removing the branch, and syncing local main. Use when the user says land or asks to run the repo landing workflow.
---

# Land Workflow

Use this skill when the user asks the AI to land work end to end.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Preconditions](#preconditions)
- [Default Path](#default-path)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Decide whether the current user message is approval to land.
2. Confirm branch, PR, checks, permissions, and local worktree state.
3. Merge using the repository or organization default merge method.
4. Sync local `main`, delete the verified topic branch, and restore any
   untracked-file stash created for this workflow.
5. Report the result with the actual merge method and branch state.

## What This Is Not

- Not a code review, test-fixing, or implementation workflow.
- Not a ship workflow for creating branches, commits, pushes, or pull requests.
- Not approval to merge from `main`, detached `HEAD`, or a branch without a
  matching pull request.
- Not permission to bypass failing or pending checks unless the user explicitly
  forces landing in the current turn and the connected account can override
  repository protections.

## Trigger Rules

- Treat a bare or direct current-turn command such as `land`, `land this`,
  `merge this PR`, or `land the current branch` as explicit approval to start
  the workflow without asking another confirmation question.
- If `land` or `merge` appears as part of a broader sentence, proceed only when
  the user is clearly asking the AI to complete the landing workflow now.
- If the message is about the land skill, landing policy, a future landing, or
  otherwise could be read as discussion instead of approval, ask one concise
  clarification question before merging.
- Do not infer approval from an earlier turn.

## Preconditions

- Confirm the current branch is a named non-`main` branch.
- Confirm the branch has an upstream remote and the local `HEAD` is pushed.
- Confirm the current branch has an open, non-draft pull request.
- Confirm the pull request head commit matches local `HEAD`.
- Confirm the pull request targets the expected base branch.
- Confirm the pull request has no unresolved merge conflicts.
- Confirm the connected account can merge the pull request.
- Confirm there are no tracked or staged local changes.
- If untracked files are present, stash them before landing and record the
  stash ref so it can be restored after the workflow.

## Default Path

- Prefer connected GitHub tools to merge the branch pull request using the
  repository or organization default merge method.
- Before merging, inspect the pull request and repository settings when
  available to confirm which merge methods are allowed. Use the default method
  exposed by the tool; do not force squash, merge commit, or rebase unless the
  user or repository policy requires it.
- Before merging, verify whether the GitHub MCP connector exposes the specific
  merge action for the session, such as `_merge_pull_request`, and use that
  MCP action when it is available.
- Use `gh` only after that exact MCP merge path has been checked and is
  unavailable, blocked, or fails.
- Compare local `HEAD` with the PR head before merging.
- Confirm required jobs, checks, and mergeability status are finished and
  passing before merging.
- After the merge completes, switch to `main` locally, sync local `main`, and
  confirm there are still no tracked or staged local changes before deleting
  the verified local topic branch.
- Restore any untracked-file stash created for this workflow after branch
  deletion or after any stop condition that leaves the worktree usable.

## Stop Conditions

- Stop if the current branch is `main`.
- Stop if HEAD is detached.
- Stop if there is no branch pull request to merge.
- Stop before merge or deletion if tracked or staged local changes are present.
- Stop if an untracked-file stash created for this workflow cannot be restored;
  report the stash ref for manual recovery.
- Stop if local `HEAD` does not match the PR head before merging.
- Stop if required jobs, checks, or mergeability status are pending, missing,
  failing, or errored.
- Proceed despite pending or failed checks only when the user explicitly says
  to force landing in the current turn and the connected account has permission
  to override repository protections.
- Account for the actual merge method used when validating that local branch
  deletion is safe.
- If a required git or GitHub command is blocked by sandbox permissions, rerun
  it with approval instead of abandoning the workflow.

## Handoff

- Use a warm, lively one-line landing phrase when the workflow succeeds, such
  as `🛬 The captain has landed cleanly. Main is shining. ✨`
- Report the final branch state.
- Say which merge method was used.
- Say whether the verified local branch was deleted.
- If landing stops or fails, skip the landing phrase and state the blocker
  plainly.

## Response Examples

Successful landing:

```text
🛬 The captain has landed cleanly. Main is shining. ✨

Merged PR #123 using the repository default merge method: squash.
Local `main` is synced, and `fix/login-crash` was deleted.
Restored the untracked-file stash.
```

Successful landing with no stash:

```text
✅ Touchdown. The branch is home.

Merged PR #124 using the repository default merge method: merge commit.
Local `main` is synced, and `feat/offline-cache` was deleted.
No local stash was needed.
```

Blocked landing:

```text
⚠️ Landing is blocked: required check `build` is still pending.

No merge was performed. Local branch and worktree were left unchanged.
```

Clarification needed:

```text
❓ Do you want me to land the current branch now?
```
