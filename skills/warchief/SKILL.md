---
name: warchief
description: Have the AI choose the next orchraft lifecycle step and hand off to the right skill, without performing git or GitHub mutations. Use when the user says warchief, asks what should happen next, or wants orchraft to route the work.
---

# Warchief Workflow

Use this skill when the user wants the clan to decide what should happen
next across the software lifecycle, instead of naming a specific skill.

## At A Glance

1. Read the user's goal and the current repo state.
2. Choose the next fitting orchraft role: `Quest-Giver`, `Tactician`,
  `Forgehand`, `Warpath`, `Raid Captain`, `Trialmaster`, `Haulmaster`, `Herald`,
   `Rune-Reader`, `Reckoner`, `Scout`, `Loremaster`, or `Chronicler`.
3. Explain the handoff briefly, then run only the step the approval policy
   says is authorized.
4. Stop before every git, PR, issue, or release mutation unless the current
   message explicitly approves that exact mutating workflow, or the verified
   default-branch copy of the approval policy or config names that exact
   action. A failed or mismatched verification is not authorization.

## Routing

- Treat user-facing role names as portable workflow roles. Run the matching
  skill on every host; when the host exposes a compatible named subagent,
  delegate to its adapter: `forgehand`, `tactician`, `scout`, `loremaster`,
  `trialmaster`, `chronicler`, or `rune-reader`. These agents stop before
  mutations that require separate approval.
- Use `Forgehand` for implementation and tests. It may edit files but never
  commits, pushes, opens a PR, posts a review, merges, or changes an issue.
- Use `Warpath` when the user explicitly asks to repeat fix → ship → roast
  until the latest roast reports zero findings. It re-reads live state after
  each cycle, pauses at approval gates, and hands off a clean PR to `land`.
- Use `Trialmaster` for read-only review findings. It may inspect code and use
  `roast`'s policy, but never posts the review.
- Use `Tactician` / `warplan` when the work needs a grounded implementation
  plan before code changes.
- Use `Quest-Giver` / `quest` when the next useful artifact is an issue or
  issue update.
- Use `Raid Captain` / `ship` only when the user explicitly asks to branch,
  commit, push, or open/update a PR in the current turn.
- Use `Trialmaster` / `roast` when the user asks for PR review or the PR is
  ready for review.
- Use `Rune-Reader` / `runes` when the user asks for status, resume, or where
  work stands.
- Use `Scout` / `yap` when the user asks to explain a file, diff, PR, policy,
  or error.
- Use `Loremaster` / `lore` when the user asks to add or clean up
  comments/docstrings.
- Use `Chronicler` / `chronicle` when the user asks to write or update a
  standalone Markdown document.
- Use `Haulmaster` / `land` only when the user explicitly asks to merge/land
  in the current turn.
- Use `Herald` / `herald` when the user asks for release notes or what a
  release shipped.
- Use `Reckoner` / `reckoning` when the user asks which review findings were
  declined rather than fixed.

Direct skill names remain supported alongside these role aliases.

If more than one route fits, choose the earliest lifecycle step that removes
real uncertainty. For example, plan before editing, status before shipping an
unknown branch, and review before landing.

## Guardrails

- Read `context/policies/approval-policy.md` before any route that could
  mutate git, PRs, issues, or releases.
- Never treat the `warchief` request itself as approval to commit, push,
  open/update/merge a PR, resolve a thread, mutate an issue, or write a
  release.
- Do not create a stored state file. Use `runes` for live status.
- Do not chain multiple mutating skills from one approval. A clean `roast`
  may make `land` the next recommendation, but `land` still needs its own
  current-turn go-ahead.
- `Warpath` is the explicit exception for orchestration, not for approval: it
  may coordinate repeated lifecycle steps, but each mutation remains gated by
  the approval policy.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Warchief from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`).
- Name the selected next role and why.
- If that role is mutating and neither the current turn nor a verified
  Autonomous Mode entry authorizes it, ask for the exact go-ahead instead of
  running it.
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
