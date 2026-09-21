---
name: warchief
description: Have the AI choose the next orchraft lifecycle step and hand off to the right skill, without performing git or GitHub mutations. Use when the user says warchief, asks what should happen next, or wants orchraft to route the work.
---

# Warchief Workflow

Use this skill when the user wants the clan to decide what should happen
next across the software lifecycle, instead of naming a specific skill.

## At A Glance

1. Read the user's goal and the current repo state.
2. Choose the next fitting orchraft role: `quest`, `warplan`, `ship`,
   `roast`, `land`, `herald`, `runes`, `reckoning`, `yap`, `lore`, or
   `chronicle`.
3. Explain the handoff briefly, then run only the step the user has actually
   authorized in this turn.
4. Stop before every git, PR, issue, or release mutation unless the current
   message explicitly approves that exact mutating workflow.

## Routing

- Use `quest` when the next useful artifact is an issue or issue update.
- Use `warplan` when the work needs a grounded implementation plan before
  code changes.
- Use `ship` only when the user explicitly asks to branch, commit, push, or
  open/update a PR in the current turn.
- Use `roast` when the user asks for PR review or the PR is ready for review.
- Use `land` only when the user explicitly asks to merge/land in the current
  turn.
- Use `herald` when the user asks for release notes or what a release
  shipped.
- Use `runes` when the user asks for status, resume, or where work stands.
- Use `reckoning` when the user asks which review findings were declined
  rather than fixed.
- Use `yap` when the user asks to explain a file, diff, PR, policy, or error.
- Use `lore` when the user asks to add or clean up comments/docstrings.
- Use `chronicle` when the user asks to write or update a standalone
  Markdown doc such as a README section or design doc.

If more than one route fits, choose the earliest lifecycle step that removes
real uncertainty. For example, plan before editing, status before shipping an
unknown branch, and review before landing.

## Guardrails

- Read `context/policies/approval-policy.md` before any route that could
  mutate git, PRs, issues, or releases.
- Never treat the `warchief` request itself as approval to commit, push,
  open/update/merge a PR, resolve a thread, or mutate an issue.
- Do not create a stored state file. Use `runes` for live status.
- Do not chain multiple mutating skills from one approval. A clean `roast`
  may make `land` the next recommendation, but `land` still needs its own
  current-turn go-ahead.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Warchief from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`).
- Name the selected next role and why.
- If that role is mutating and the user did not approve it in the current
  turn, ask for the exact go-ahead instead of running it.
- If a non-mutating role fits and no approval is needed, run it directly.

## Examples

```text
Chief, the council calls for `runes` first: this branch's PR state is unknown.
Reading the board before we swing.
```

```text
Chief, `ship` is the next march, but that means branch/commit/push/PR work.
Say "ship it" and we move.
```
