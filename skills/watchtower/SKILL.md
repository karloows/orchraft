---
name: watchtower
description: Have the AI surface a short read-only status nudge about open PR work without mutating git or GitHub. Use when the user says watchtower, asks for a session-start nudge, or wants proactive PR status.
---

# Watchtower Workflow

Use this skill to give the chief a quiet status nudge at session start or
resume, before the user has re-explained what work is in flight.

When installed as the plugin, `hooks/hooks.json` already fires this nudge
automatically on `SessionStart` (`startup`/`resume`/`clear`/`compact`) via
`hooks/watchtower-nudge.sh`, a deterministic script covering the same rules
below without a nested model call. This skill file is what a user invokes
directly (`/watchtower`) and is also the source of truth the hook script
mirrors — keep them in sync if the surfacing rules change.

## At A Glance

1. Inspect live state for the current branch and its pull request, following
   the same source-of-truth rules as `runes`.
2. If there is something worth interrupting for, say it in one short line.
3. Stop. Never commit, push, merge, comment, resolve threads, or update
   issues.

## What To Surface

Surface only actionable live facts:

- an open PR with unresolved `roast` findings
- a PR whose checks are failing or pending
- a local branch with uncommitted work and no PR
- a clean PR that is ready for `land`

Say nothing when there is no meaningful status to report. A quiet watchtower
is working as intended.

## Guardrails

- Read live git/GitHub state; do not use memory from earlier turns.
- Do not create or read a stored status file.
- Do not infer approval for any next step. A nudge can name `ship`, `roast`,
  or `land` as the likely next move, but the chief must ask for that workflow
  in the current turn.
- Keep the line plain and low-noise. This skill may run unasked, so avoid
  celebration, sounds, long summaries, or repeated context.
- If GitHub status cannot be checked, say only the local fact that is known,
  or stay silent if the local state is uninteresting.

## Handoff

- Use the Watchtower voice from `context/personality.md` (the target repo's
  copy when it exists, otherwise `${CLAUDE_PLUGIN_ROOT}/context/personality.md`).
- Output one line, then stop.

## Examples

```text
Chief, PR #142 still carries 2 open cracks from the last roast.
```

```text
Chief, `feat/offline-cache` has local changes and no PR yet.
```

```text
Chief, PR #145 is green and clean; land is the next call.
```
