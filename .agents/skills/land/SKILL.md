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
3. Resolve the merge method, then merge.
4. Sync local `main`, verify the branch actually landed before deleting it,
   and restore any local-changes stash created for this workflow.
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

- Read the target repo's config file — `.orchraft.jsonc`, else
  `.orchraft.json` — when one exists, per `context/policies/config-policy.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/policies/config-policy.md`). Both allow `//`
  comments. A missing file is the normal case and means the documented
  defaults apply. The config file is always read from the repository being
  worked in, never from the plugin's own directory.
- Confirm the current branch is a named non-`main` branch.
- Confirm the branch has an upstream remote and the local `HEAD` is pushed.
- Confirm the current branch has an open, non-draft pull request.
- Confirm the pull request head commit matches local `HEAD`.
- Confirm the pull request targets the expected base branch.
- Confirm the pull request has no unresolved merge conflicts.
- Confirm the connected account can merge the pull request.
- Confirm required check status by reading it fresh from the connected tool
  in the current turn; don't assume it from an earlier turn or a prior pass.
- If tracked, staged, or untracked local changes are present, stash all of
  them (including untracked files) before landing and record the stash ref.

## Default Path

- Prefer connected GitHub tools to merge the branch pull request.
- Resolve the merge method before merging, stopping at the first source that
  answers, per the config policy named in Preconditions:
  1. What the user asked for in the current turn.
  2. `merge.method` in the target repo's config file, when set to
     something other than `"repo"`.
  3. The repository's allowed methods. GitHub exposes `allow_merge_commit`,
     `allow_squash_merge`, and `allow_rebase_merge` — which methods are
     *permitted*, not which is preferred, and they read as `null` for an
     account without push access. When exactly one is allowed, that is the
     answer and no further step runs.
  4. The base branch's recent history, when more than one method is allowed
     and nothing above chose. A merge commit has two parents; a squashed
     commit has one and usually a trailing `(#123)`. Follow what the
     repository actually does, and say in the handoff that the method was
     inferred rather than configured.
  5. Ask the user, when the history is empty or mixed.
- A method the repository forbids is a stop, not a fallback: report that the
  requested method is disallowed instead of quietly using another one.
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
  the verified local topic branch. Skip the deletion entirely when
  `merge.deleteLocalBranch` is `false` in the target repo's config file,
  and say so in the handoff.
- Verify the branch actually landed before deleting it, using the check that
  matches the merge method:
  - **Merge commit** — the branch's tip is an ancestor of the base branch, so
    `git branch --merged main` lists it and `git branch -d` succeeds. Use
    `-d` and let it refuse if something is wrong.
  - **Squash or rebase** — the commits on the base branch are new objects, so
    the topic branch's tip is *not* an ancestor of it. `git branch --merged`
    will not list the branch and `git branch -d` will refuse with "not fully
    merged" even though the work landed correctly. Confirm the landing
    another way before deleting: the pull request reports `merged: true` with
    a merge commit SHA, and `git diff <base> <branch>` is empty, meaning the
    branch's content reached the base branch. Only then delete with
    `git branch -D`.
- Never reach for `git branch -D` because `-d` refused. Establish that the
  work landed first; a refusal that has not been explained is a stop, not a
  prompt to force.
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
  deletion is safe; see the Default Path for the check each method needs.
- Stop if the merge method resolved from the config file or from the user is
  one the repository does not allow.
- Stop if `git branch -d` refuses after a merge-commit landing — that means
  the branch did not land as expected. Do not escalate to `-D` to get past
  it.
- If a required git or GitHub command is blocked by sandbox permissions, rerun
  it with approval instead of abandoning the workflow.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line success
  phrase in the orc voice, speaking as the Haulmaster from
  `context/personality.md` (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with the
  plain result instead.
- Report the final branch state.
- Say which merge method was used and where it came from: the user,
  the config file, the only method the repository allows, or an inference
  from the base branch's history. An inferred method is reported as inferred.
- Say whether the verified local branch was deleted, and when it was kept,
  why — `merge.deleteLocalBranch` being `false`, or a landing that could not
  be verified.
- If landing stops or fails, skip the landing phrase and state the blocker
  plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Successful landing:

```text
🏰 Rrraaagh! Victory march into main. The branch banner rests with honor. ✨

Merged PR #123 with squash, the only method this repository allows.
Local `main` is synced, and `fix/login-crash` was deleted.
Restored the local stash.
```

Successful landing with no stash:

```text
🏰 Gates opened on green. Spoils carried home, feast hall ready.

Merged PR #124 with a merge commit, inferred from the base branch's history.
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
