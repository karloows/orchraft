---
name: lore
description: Have the AI add or fix code comments and docstrings across a diff or file so they match this repo's lore policy, in whatever language or framework it's written in. Use when the user says lore, asks to comment the code, add docstrings, document a function, or clean up stale/noisy comments.
---

# Lore Workflow

Use this skill when the user asks the AI to write, fix, or clean up in-code
comments and docstrings — the clan calls this "lore."

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Requirements](#requirements)
- [Prerequisites](#prerequisites)
- [Targets](#targets)
- [Default Path](#default-path)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Read `context/policies/lore-policy.md` for the shape rules.
2. Figure out the [target](#targets): the current diff by default, or a
   file/PR the user names.
3. For each function/class/module in scope, add a docstring only where the
   policy calls for one, fix one that's wrong, and strip a comment that
   violates the policy (states the obvious, stale, decorative).
4. Leave already-compliant lore untouched.
5. Report what changed, file:line. Never commit, push, or open/update a PR —
   that's `ship`'s job.

## What This Is Not

- Not `ship`: it never stages, commits, or pushes. Run `ship` afterward to
  land the lore changes.
- Not `roast`: it edits code directly instead of posting findings for someone
  else to fix.
- Not a documentation generator for README/external docs sites — scope is
  in-source comments and docstrings only.
- Not permission to touch code logic. If a docstring reveals a bug, say so
  and stop; don't fix the bug as part of this skill unless the user asks.

## Trigger Rules

- Run when the user explicitly asks to lore, comment the code, add
  docstrings, document a function/file, or clean up comments.
- If the target is ambiguous (no file, diff, or PR implied and none is the
  obvious current work), ask which scope before editing anything.

## Requirements

The diff and file targets need nothing beyond local git and file access. The
pull request target additionally needs a GitHub MCP connector configured for
this session (read access is enough — this skill never posts to GitHub), or
`gh` installed and authenticated as a fallback. Without either, stop and tell
the user the PR target isn't reachable and ask whether to use the local diff
or a named file instead — don't silently substitute a different scope for
the one they asked for.

## Prerequisites

- Read `context/policies/lore-policy.md`. Use the target repo's copy when it
  exists; otherwise use the bundled copy at
  `${CLAUDE_PLUGIN_ROOT}/context/policies/lore-policy.md`.
- Check `git status --short` to know what's actually in scope before editing.
- Identify the doc-comment syntax the file/language already uses (JSDoc,
  Google-style Python, Rustdoc, godoc, etc.) from existing examples in the
  repo; don't invent a format the codebase doesn't use.

## Targets

- **Current diff (default)** — unstaged and staged changes from
  `git diff` / `git diff --staged`, plus new files reported as untracked by
  `git status --short` (`git diff` alone won't show them). Scope lore edits
  to the functions, classes, and modules the diff actually touches or adds.
- **File(s)** — when the user names a file or path, scope to that file only.
- **Pull request** — when the user names a PR, fetch its diff through the
  GitHub MCP connector (falling back to `gh`) and scope to the files it
  touches, applied to the local working tree on that branch.

## Default Path

1. Determine the target and read `context/policies/lore-policy.md`.
2. List the functions/classes/modules in scope.
3. For each: add a docstring if the policy calls for one and none exists, fix
   one that's inaccurate or missing a non-obvious param, and remove/rewrite
   any inline comment that restates the code, is stale, or is decorative.
4. Match the existing doc-comment syntax for that language; don't mix
   conventions within a file.
5. Skip anything already compliant — don't touch it just to reformat it.
6. Report the changes as a file:line list, grouped by file.

## Guardrails

- Never commit, push, stage, or touch a PR/issue as part of this skill.
- Never change code behavior — comments and docstrings only.
- Never invent behavior the code doesn't have; ground every docstring in
  what the function actually does, not what its name suggests it should do.
- Don't add a comment or docstring the policy says to skip (trivial
  one-liners, self-explanatory signatures) just to raise coverage.

## Stop Conditions

- Stop and ask if there's no identifiable target (no diff, no named file, no
  current work to infer from).
- Stop if a docstring pass reveals the code doesn't do what its name or an
  existing comment claims — report the mismatch instead of silently
  "documenting" the bug away.
- Stop if the file's existing doc-comment convention is unclear and no repo
  example resolves it — ask instead of guessing a format.
- Stop if the user asked for the pull request target and neither the GitHub
  MCP connector nor `gh` is available — ask whether to use the diff or a
  named file instead of silently switching targets.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Loremaster from
  `context/personality.md` (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with the
  plain result instead.
- List the files touched and a one-line count of what changed (added/fixed/
  removed).
- Remind the user that `ship` is the next step if they want these changes
  committed.
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Lore added to a diff:

```text
📜 Hrrm. Etched the missing runes into three new functions. ✨

`src/auth/token.ts`: added 2 docstrings, fixed 1 stale comment.
`src/auth/session.ts`: added 1 docstring.
Run `ship` to carry this into a commit.
```

Nothing to add:

```text
📜 Hah! The armory's already marked true. Nothing to etch here.

Scanned the current diff — every function already carries accurate lore.
```

Blocked, no target:

```text
❓ Chief, what should we mark: the current diff, a file, or a PR?
```
