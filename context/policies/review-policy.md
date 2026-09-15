# Review Policy

This policy defines how an AI reviewing a pull request's diff — such as the
`roast` skill — ranks findings and reports them. User instructions,
project-local rules, `AGENTS.md`, and higher-priority repo instructions still
take precedence — a target repo's own review conventions (a CONTRIBUTING
guide, PR template checklist, or CI-enforced review gate) override this
default.

## Purpose

Keep review focused on real regressions, repo fit, and missing verification,
not vague approval language or style nits dressed up as issues.

## Reviewer Priorities

Review in this order:

1. Security exposure, data loss, or the change can't run/build at all.
2. Regressions or broken behavior introduced by the change.
3. Required policy violations (branch, commit, or PR-text format; direct push
   to `main`) — only where the repo actually has that policy; this file may be
   copied into a repo without `branch-policy.md`/`commit-policy.md`, so skip
   this tier rather than inventing a rule the repo doesn't enforce.
4. Repo structure issues: file/package placement, dependency direction, or
   generated-output leakage that conflicts with repo conventions.
5. Copy accuracy: package names, command names, environment variable names,
   and repository terminology.
6. Scope control: unrelated refactors or pattern changes the task didn't
   require.
7. Missing, weak, or overly implementation-coupled verification for the
   touched area.

This order matters because it keeps review focused on actual breakage first.
A style nit is not more important than a change that can break a contract or
weaken a check that used to exist.

## Severity Guide

- **Critical** — merge-blocking: security exposure, data loss, the change
  can't run/build at all, a required policy violation, or the PR is missing
  something the linked task explicitly asked for.
- **Important** — a recoverable correctness defect that doesn't block merge
  (an ordinary bug, a missing edge case a real user hits, an inconsistent
  pattern, drift from an established convention).
- **Minor** — cosmetic or non-blocking (naming nit, optional polish).

## Findings Format

Report each finding tied to a concrete file or behavior:

`[SEVERITY] <one-line finding> — <why it matters / what to do>`

- Keep each finding specific and technically actionable.
- State the impact or risk, not just the symptom.
- Omit praise, narration, or generic approval text.

The format line above defines what a finding must contain. A review skill
may present the same fields with its own formatting when it posts them.

Findings should read like review notes another engineer can act on
immediately. If a comment can't point to a concrete risk or fix, it usually
doesn't belong in the findings list.

Something that looks wrong but isn't backed by a policy or a visible repo
convention is a judgment call, not a violation — tag it `[JUDGMENT CALL]`
instead of a severity, so it reads as a suggestion rather than an enforced
rule the repo doesn't actually have.

## Open Questions

Use open questions only when a real ambiguity remains after reviewing the
repo context and instructions.

`Open question: <concise question and why it blocks confidence>`

- Do not convert known defects into open questions.
- Do not ask for confirmation on behavior that repo instructions already
  define.

## No-Issue Case

If no findings remain, say so directly and still mention any real validation
gap or residual risk. No findings does not mean perfect certainty — if part
of the diff couldn't be reviewed (e.g. generated/vendored files, a truncated
diff), say that plainly instead of implying full coverage.
