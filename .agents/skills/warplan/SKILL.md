---
name: warplan
description: Have the AI draft an implementation plan grounded in this repo's own conventions, policies, and precedent before code gets written. Use when the user says warplan, asks to plan a feature or fix, wants a design pass before implementation, or asks how to approach a change.
---

# Warplan Workflow

Use this skill when the user wants a plan for how to implement something,
grounded in what this repo actually does rather than generic best practice —
the lifecycle stage before writing code and, eventually, `ship`.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Plan Format](#plan-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Pin down what's being planned and how much is already decided.
2. Ground the plan in this repo's real precedent: similar existing code,
   `context/policies/`, `AGENTS.md`/`CLAUDE.md`, and comparable past
   commits/PRs, not generic architecture advice.
3. Write the plan: approach, the files/areas it touches, tradeoffs, risks,
   validation strategy, and open questions.
4. Stop. Never write code, commit, push, or touch a PR/issue as part of this
   skill — that's implementation and `ship`'s job, after the chief signs off
   on the plan.

## What This Is Not

- Not an implementation workflow. It produces a plan to review, not a diff.
- Not `ship`: no branch, commit, push, or PR happens here even after the
  plan is approved — that's a separate, later step.
- Not `yap`: yap explains what already exists; warplan proposes what to
  build next.
- Not a replacement for the host tool's own plan-mode UI, if it has one.
  This skill's value is grounding the plan in this specific repo's
  conventions and precedent, not the planning interaction itself.
- Not permission to start implementing once the plan is written. A plan
  being ready is not a `ship` go-ahead.

## Trigger Rules

- Run when the user explicitly asks to warplan, plan a feature/fix, design
  an approach, or asks "how should we build/approach this" before writing
  code.
- If the task is too vague to plan (no goal, no scope, no constraints given),
  ask one concise clarification question instead of guessing the scope.
- Do not run automatically before every implementation task; only when the
  user asks for a plan first.

## Prerequisites

- Read whichever of `context/policies/branch-policy.md`,
  `context/policies/commit-policy.md`, `context/policies/writing-guidelines.md`,
  `context/policies/review-policy.md`, `context/policies/lore-policy.md`,
  and `context/policies/approval-policy.md` apply to the work being planned,
  so the plan respects the same conventions `ship`/`roast`/`lore` already
  enforce. Use the target repo's copy of each when it exists; otherwise use
  the bundled copy at `${CLAUDE_PLUGIN_ROOT}/context/policies/<file>`.
- Read `AGENTS.md`/`CLAUDE.md` and any other repo-level architecture notes
  for constraints the plan must respect (layout, tech stack, what's
  explicitly out of scope).
- Search the repo for the closest existing precedent: a similar feature,
  a comparable past PR (via git log or the GitHub MCP connector), or an
  existing pattern the new work should follow rather than reinvent. When the
  scope spans several plausible precedent areas (e.g. a change touching more
  than one skill, policy, or subsystem), split that search across parallel
  read-only subagents (e.g. `Explore`) instead of working through them
  serially — each takes a disjoint area to search plus the relevant sources
  above and returns findings only. It may read git history and GitHub
  PRs/issues to find precedent (the same lookups this step already uses),
  but holds no write tools of any kind — it cannot write code, create commits,
  push, or create, modify, comment on, or otherwise mutate PRs or issues.
  This skill still evaluates every returned lead,
  decides which precedent actually grounds the plan, and writes the plan
  itself — a subagent gathers candidate precedent, it never decides what the
  plan says.

## Default Path

1. Confirm the goal and scope with the user if either is unclear.
2. Gather grounding: relevant policies, architecture docs, and the closest
   existing code/PR precedent for this kind of change.
3. Identify the files/areas the change would touch, based on where the
   precedent lives, not a guess at the repo's layout.
4. Draft the plan per [Plan Format](#plan-format) below.
5. Surface real tradeoffs or risks the chief should weigh, and open
   questions that block a confident plan, rather than picking silently and
   hoping it's right.
6. Stop and hand the plan back for review. Do not start implementing.

## Plan Format

Keep it scoped to what was asked — not a tour of the whole codebase.

- **Goal** — what the change accomplishes and why, in one or two sentences.
- **Approach** — the concrete implementation strategy, grounded in the
  precedent found during Prerequisites (cite the file/PR it follows).
- **Touches** — the files or areas the change would create or modify.
- **Tradeoffs** — real alternatives considered and why this approach won
  out, when more than one reasonable path exists.
- **Risks** — what could break, what's hard to reverse, or what needs a
  careful rollout.
- **Validation** — what would confirm the change works, per
  `context/policies/verification-policy.md`.
- **Open questions** — anything that needs the chief's answer before
  implementation can start confidently. Omit this section when there are
  none; don't invent a question to seem thorough.

## Guardrails

- Never write, edit, commit, or push code as part of this skill.
- Never touch a PR or issue as part of this skill.
- Never invent a codebase convention or architecture constraint that isn't
  actually visible in the repo; say when something is a judgment call
  instead of stating it as established practice.
- Don't pad the plan with sections that don't apply (e.g. Tradeoffs when
  there's only one reasonable approach).
- A subagent used for the parallel precedent search may read git history and
  GitHub PRs/issues but gets no write tools of any kind — it must not be
  able to write code, commit, push, or touch a PR or issue. Its findings are
  input to this skill's own evaluation and plan, and are never treated as
  the plan itself.

## Stop Conditions

- Stop and ask one clarification question if the goal or scope is too
  vague to ground a plan in real precedent.
- Stop if no relevant precedent, policy, or architecture doc exists to
  ground part of the plan — say that plainly instead of inventing a
  convention the repo doesn't have.
- Stop after handing back the plan; do not proceed to implementation
  without the user separately asking for it.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Tactician from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain plan instead.
- Present the plan per [Plan Format](#plan-format).
- Note which precedent (file, PR, or policy) grounded the approach.
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Plan drafted:

```text
🗺️ Hrrm. Plan drawn: three files to breach, one open question for the chief. ✨

Goal: ...
Approach: ...
Touches: ...
Open questions: ...
```

Blocked, scope too vague:

```text
❓ Chief, what should the plan cover — which feature or fix, and any hard
constraints?
```

Blocked, no precedent found:

```text
⚠️ Warplan can't ground the auth approach: no comparable pattern exists in
this repo yet. Proceeding would mean inventing a convention, not following
one — say if you want that anyway.
```
