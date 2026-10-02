---
name: warpath
description: Run the fix, ship, and roast cycle for an open pull request until the latest roast reports zero findings. Use when the user asks to repeat review fixes until clean or run the review loop.
---

# Warpath Workflow

Use this skill when the user wants Orchraft to keep cycling through review
findings instead of stopping after one ship or roast pass.

## At A Glance

1. Read the live branch and pull-request state with `runes`.
2. If findings exist, hand them to `Forgehand` for fixes.
3. When fixes are ready, hand off to `Raid Captain` / `ship`.
4. Run `Trialmaster` / `roast` against the new pull-request head.
5. Repeat from step 2 until the latest roast reports zero findings.
6. Recommend `Haulmaster` / `land`; do not merge as part of this loop.

## Completion

The loop is complete only when the latest roast pass ran against the current
PR head and reported zero findings. A successful ship, passing checks, or zero
unresolved threads from an older head is not completion.

If a finding is declined, keep it visible and stop for the user's decision;
declining is not zero findings. If checks fail, the PR disappears, or the
review cannot be posted, stop and report the blocking state.

## Approval

Read `context/policies/approval-policy.md` before starting. This workflow is
an orchestrator, not a permission grant: pause before every commit, push, PR
update, review, thread resolution, or other mutation unless the target repo's
verified Autonomous Mode explicitly names that action. Landing always remains
a separate, explicit user request.

Do not create a stored loop state file. Re-read live git and GitHub state after
each handoff so a resumed run cannot mistake a stale roast for a clean one.

## Handoff

Open with a short orc-voice line, name `Warpath`, and state the current cycle.
Report every cycle's finding count and PR head. When clean, hand off to
`Haulmaster` / `land` instead of invoking it.
