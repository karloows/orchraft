# Verification Policy

This policy defines what "validated" means before a skill reports a change as
ready to ship or land. It applies to `ship`, `land`, and any workflow that
claims a change works. A target project's own build/lint/test commands and CI
config override the defaults below.

## Purpose

Keep validation real. An agent must run the smallest relevant check and show
its actual result, not assert that something "should work," "looks correct,"
or "passes" without having run it.

## What Counts As Validation

In priority order, use whatever the target repo actually has:

1. A project-defined command (`package.json` script, `Makefile` target, CI
   config step, or a command named in `AGENTS.md`/`CLAUDE.md`/a project
   skill). Run the same command CI runs, not a hand-picked substitute.
2. The narrowest command that exercises the touched area (a single test file
   or package) over a full-suite run, when the repo supports scoping.
3. For changes with no runnable check (docs, prose, config comments), say
   plainly that the change was reviewed by reading, not executed.

Never invent a command the repo doesn't have, and never skip an existing one
because it's slow.

## Reporting The Result

- State the exact command run and its outcome (pass/fail), not a paraphrase.
- If a check fails, show what failed, not just "some tests failed."
- If nothing runnable applies, say so instead of implying a check occurred.
- Never report a check as passing without having run it in the current turn.
  A check that passed earlier in the conversation does not carry forward past
  a further edit to the touched files.

## On Failure

- Stop before committing, pushing, or opening/updating a pull request.
- Fix the root cause when it's within the scope of the current change.
- If the user explicitly asks to proceed despite a failure, report the
  failure plainly in the handoff and do not describe the change as validated.

## Edge Cases

- **Can't run vs. ran and failed.** If a check can't run at all (missing
  dependencies, no network, sandbox restriction, tool not installed), say
  that plainly and distinguish it from a check that ran and failed. Don't let
  "couldn't run" read as "passed."
- **Flaky results.** If a check fails, re-run it at most once. If the second
  run passes, note that it was flaky. If it fails again, treat it as a real
  failure — don't keep retrying until it happens to go green.
- **Pre-existing failures.** If a check fails for a reason clearly unrelated
  to the current diff (confirm by checking whether it also fails on the base
  branch before this change), don't block on it, but name the failing check
  and state that it predates this change instead of silently excluding it.
- **Multiple checks.** When more than one check applies (lint, typecheck,
  tests), report each one's outcome individually. Don't collapse a mix of
  pass/fail into a single "validated" claim.

## Project Overrides

A target repo's CI configuration, test runner, or CONTRIBUTING guide defines
the actual commands and required checks. This policy sets the behavior
(run something real, report it honestly, stop on failure); the target repo
sets the specifics.
