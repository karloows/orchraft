---
name: chronicle
description: Have the AI draft or update a standalone Markdown doc — a feature write-up, design doc, or a section of README/ROADMAP — grounded in the real diff, code, commit history, or PR/issue text. Use when the user says chronicle, asks to write documentation, draft a design doc, or update a doc file, or wants a feature explained outside of in-code comments.
---

# Chronicle Workflow

Use this skill when the user asks the AI to write or update a standalone
Markdown document — anything that isn't an in-code comment or docstring.

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

1. Read `context/policies/docs-policy.md` for the shape rules.
2. Figure out the [target](#targets): a diff/PR/feature to document, an
   existing doc file to update, or a new one to create.
3. Ground every claim in something readable — code, commit history, or
   PR/issue text. Never invent intent, history, or rationale that isn't
   recoverable from a real source.
4. Draft or update the doc content directly in the file.
5. Report what changed, file and section. Never commit, push, or open/update
   a PR — that's `ship`'s job.

## What This Is Not

- Not `ship`: it never stages, commits, or pushes. Run `ship` afterward to
  land the doc changes.
- Not `lore`: `lore` writes in-code comments and docstrings; `chronicle`
  writes standalone Markdown documents — README, ROADMAP, design docs,
  feature write-ups — and never touches a source file's comments.
- Not `yap`: `yap` explains in chat, read-only, and produces no file. This
  skill produces or updates an actual document.
- Not permission to invent rationale, history, or intent the repo doesn't
  actually show. If the "why" behind a change isn't recoverable from code,
  commit history, or PR/issue text, say so and ask instead of narrating a
  plausible-sounding reason.

## Trigger Rules

- Run when the user explicitly asks to chronicle, write documentation, draft
  a design doc or feature write-up, or update a doc file (README, ROADMAP,
  or any other standalone Markdown doc).
- If both the target doc and the thing it should document are ambiguous, ask
  which before writing anything.

## Requirements

- A diff, file, or new-file target needs nothing beyond local git and file
  access.
- A PR or issue target additionally needs a GitHub MCP connector configured
  for this session (read access is enough — this skill never posts to
  GitHub), or `gh` installed and authenticated as a fallback. Without
  either, stop and tell the user the PR/issue target isn't reachable and ask
  whether to use the local diff or a named file instead.

## Prerequisites

- Read `context/policies/docs-policy.md`. Use the target repo's copy when it
  exists; otherwise use the bundled copy at
  `${CLAUDE_PLUGIN_ROOT}/context/policies/docs-policy.md`.
- Check `git status --short` and the relevant diff to know what actually
  changed before drafting anything grounded in it.
- Read the target document's existing structure and tone (or the closest
  comparable doc in the repo, when creating a new file) before writing —
  match it instead of imposing a different convention.
- Read `context/personality.md` (target repo copy, else bundled) to confirm
  whether the target file/section is one where the orc voice actually
  applies — most document *content* stays plain and technical; the voice is
  reserved for the specific surfaces that file lists (e.g. a README
  introduction), not for design docs or ROADMAP entries.

## Targets

- **Diff, PR, or named feature/change** — ground the doc content in what
  actually changed: `git diff`/`git diff --staged` plus untracked files, or
  a PR's diff fetched through the GitHub MCP connector (falling back to
  `gh`).
- **Existing file or section** — update a named doc file or one section of
  it, matching its current structure and tone.
- **New file** — create a doc that doesn't exist yet (e.g. a first
  `CONTRIBUTING.md`), grounded in the same real sources as any other
  target. Never fill a new doc with placeholder filler ("add details here")
  where a real source doesn't yet cover something — say what's missing
  instead.

## Default Path

1. Determine the target and read `context/policies/docs-policy.md`.
2. Identify what the doc needs to say, grounded in the diff, code, commit
   history, or PR/issue text — not assumption or house style guessing.
3. Match the existing document's structure and tone, or the plain,
   technical default from `context/policies/docs-policy.md` when creating a
   new file with no comparable precedent in the repo.
4. Draft or update the content directly in the file.
5. Report the changes as a file/section list.

## Guardrails

- Never commit, push, stage, or touch a PR/issue as part of this skill.
- Never touch in-code comments or docstrings — that's `lore`'s job, not
  this one's.
- Never invent rationale, history, features, or claims not grounded in a
  real, readable source.
- Don't pad a doc with generic filler that carries no real information;
  every sentence should say something specific about this repo.

## Stop Conditions

- Stop and ask if there's no identifiable target and no current work to
  infer one from.
- Stop if the "why" behind a change isn't recoverable from any real source
  — report the gap instead of inventing a plausible-sounding reason.
- Stop if the user asked for a PR/issue-grounded target and neither the
  GitHub MCP connector nor `gh` is available — ask whether to use the diff
  or a named file instead of silently switching targets.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Chronicler from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain result instead. This orc-voice line is the skill's own success
  message, not part of the drafted document's content.
- List the files/sections touched and a one-line summary of what changed.
- Remind the user that `ship` is the next step if they want these changes
  committed.
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Doc drafted:

```text
📚 Hrrm. The feature's story is bound into the chronicle now. ✨

`docs/offline-cache.md`: new design doc, grounded in PR #58's diff and its
linked issue.
Run `ship` to carry this into a commit.
```

Doc updated:

```text
📚 The scrolls now read true. README's Install section matches what's
actually shipped.
```

Blocked, no target:

```text
❓ Chief, what should the chronicle cover, and where does it belong —
README, ROADMAP, or a new doc?
```

Blocked, ungrounded claim:

```text
⚠️ Chronicle can't say why the retry limit is 3 — nothing in the diff,
commit history, or the linked issue states a reason. Say if you want it
documented as an open question instead of a guess.
```
