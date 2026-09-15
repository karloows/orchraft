---
name: yap
description: Have the AI explain something — a PR/diff, a file or module, an error or log, a repo policy, or a dependency/changelog — grounded in real sources (code, git history, docs, policies) with citations, not a confident guess. Use when the user says yap, asks "explain this", "why does this exist", "what changed here", or wants a walkthrough of an error or unfamiliar code.
---

# Yap Workflow

Use this skill when the user asks the AI to explain something and wants the
explanation grounded in what's actually in the repo or its history, not a
generic description.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Targets](#targets)
- [Default Path](#default-path)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Figure out what the user wants explained and which [target](#targets) it
   is.
2. Gather the real sources for that target — code, diff, git history, repo
   docs/policies, or the error/log itself.
3. Explain it grounded in those sources, citing file:line, commit, or doc
   references instead of asserting from general knowledge alone.
4. Stop. This skill never edits files, comments on anything, or opens/changes
   a PR.

## What This Is Not

- Not `roast`: it doesn't judge, flag policy violations, or post anywhere.
  Yap explains; roast reviews.
- Not a fix workflow. If the explanation reveals a bug, say so and stop —
  don't start editing unless the user separately asks.
- Not permission to guess when the grounding sources don't cover something.
  Say what's unclear or unverifiable instead of filling the gap with a
  plausible-sounding guess.

## Trigger Rules

- Run when the user explicitly asks to yap, explain, walk through, or answer
  "why"/"what changed"/"what does this do" about something in or around the
  repo.
- If the ask is ambiguous about what to explain (no file, PR, error, or topic
  named), ask one concise clarification question instead of guessing the
  target.

## Targets

Pick the grounding sources based on what's being explained:

- **PR / diff** — the PR's diff, commit history, description, and linked
  issue/task, fetched through the GitHub MCP connector (falling back to
  `gh`). Explain what changed and why, citing file:line from the diff.
- **File / module** — the file's current content plus `git log -p` /
  `git blame` on it for why it's shaped the way it is, and any repo docs
  (`CLAUDE.md`, `AGENTS.md`, `README.md`) that describe its role.
- **Error / log / stack trace** — trace the call path through the actual
  source the trace points to; don't explain the error message generically
  without checking what the referenced code does.
- **Repo policy / rule** — the policy file itself
  (`context/policies/*`, CI config, lint config) including any rationale
  section it already has.
- **Dependency / version bump** — the package's actual changelog/release
  notes (if not vendored locally, fetch them with a web fetch or search tool
  when one is available) rather than inferring risk from the version number
  alone.

If the target doesn't fit any of these, ground it in whatever the closest
real source is (repo code, git history, or fetched docs) and say which
source(s) were used.

## Default Path

1. Identify the target and its type from the list above.
2. Gather the grounding sources for that type before writing anything.
3. Read enough of each source to explain accurately — don't stop at a
   filename or a one-line diff hunk if the surrounding context changes the
   answer.
4. Write the explanation citing what was used (file:line, commit SHA, doc
   name, changelog link). Keep it scoped to what was actually asked, not a
   tour of the whole file or repo.
5. If a grounding source is missing or unavailable (no PR, no history, no
   changelog found), say so explicitly rather than filling the gap.

## Guardrails

- Never edit files, commit, push, or touch a PR/issue as part of this skill.
- Never state something as fact without a source backing it; flag inference
  as inference.
- Keep explanations scoped to what was asked — no unrelated tangents about
  other parts of the codebase.

## Stop Conditions

- Stop and ask one clarification question if there's no identifiable target.
- Stop if the named target doesn't exist (no such PR, file, or dependency) —
  say so instead of explaining something adjacent as if it were the target.
- If grounding sources are thin or unavailable, explain what's known, then
  state plainly what couldn't be verified.

## Handoff

- Use a warm, lively one-line phrase when the explanation is delivered, such
  as `🗣️ Yapped. Grounded in the actual source, not vibes. ✨`
- Note which sources backed the explanation (e.g. "based on the PR diff and
  commit history").
- If blocked, skip the lively phrasing and state the blocker plainly.

## Response Examples

Explained a PR:

```text
🗣️ Yapped. Grounded in the actual source, not vibes. ✨

Explained PR #124 based on its diff and commit history.
```

Explained an error:

```text
🗣️ Yapped, traced straight through the call path. ✨

Root cause is in `src/auth/token.ts:42` — traced from the stack trace you
pasted.
```

Blocked, no target:

```text
❓ What do you want yapped about — a PR, a file, an error, a policy, or a
dependency?
```
