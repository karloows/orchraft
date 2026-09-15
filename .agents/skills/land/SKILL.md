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
   local-changes stash created for this workflow.
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
- Merging falls under `context/policies/approval-policy.md` (the target repo's
  copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/policies/approval-policy.md`); the direct
  commands above are that policy's current-turn go-ahead.

## Preconditions

- Confirm the current branch is a named non-`main` branch.
- Confirm the branch has an upstream remote and the local `HEAD` is pushed.
- Confirm the current branch has an open, non-draft pull request.
- Confirm the pull request head commit matches local `HEAD`.
- Confirm the pull request targets the expected base branch.
- Confirm the pull request has no unresolved merge conflicts.
- Confirm the connected account can merge the pull request.
- If tracked, staged, or untracked local changes are present, stash all of
  them (including untracked files) before landing and record the stash ref.

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
- After branch deletion, restore any local-changes stash created for this
  workflow with `git stash pop` or the repository-equivalent restore command.
- If landing stops after creating a stash for this workflow, restore it once
  the worktree is usable.

## Stop Conditions

- Stop if the current branch is `main`.
- Stop if HEAD is detached.
- Stop if there is no branch pull request to merge.
- Stop if local changes cannot be stashed cleanly (e.g. an existing conflicting
  stash or a stash command failure); do not merge or delete the branch.
- Stop if a stash created for this workflow cannot be restored after landing;
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

- Open with a fresh one-line success phrase in the orc voice, speaking as the
  Haulmaster from `context/personality.md` (the target repo's copy when it
  exists, otherwise `${CLAUDE_PLUGIN_ROOT}/context/personality.md`).
- Report the final branch state.
- Say which merge method was used.
- Say whether the verified local branch was deleted.
- If landing stops or fails, skip the landing phrase and state the blocker
  plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Successful landing:

```text
🏰 Rrraaagh! Victory march into main. The branch banner rests with honor. ✨

Merged PR #123 using the repository default merge method: squash.
Local `main` is synced, and `fix/login-crash` was deleted.
Restored the local stash.
```

Successful landing with no stash:

```text
🏰 Gates opened on green. Spoils carried home, feast hall ready.

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
❓ Chief, land the current branch now?
```
