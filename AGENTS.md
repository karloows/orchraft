# orchraft

orchraft contains reusable agent workflow guidance that can be copied
into other projects. Keep this file as the map, not the rulebook: detailed
branch, commit, PR, ship, and land behavior lives in the files linked below.

## Non-Negotiable: Ask Before Every Mutating Action

No skill, policy, or agent session may do any of the following without the
user's explicit go-ahead **in the current turn**:

- Commit.
- Push.
- Create or update a branch.
- Create, update, or merge a pull request.
- Post a PR comment or review.

This applies every single time one of these is about to happen — including a
follow-up fix on a PR that's already open. Approval does not carry forward:
finishing one `ship` or `review` pass does not authorize the next one, even
minutes later in the same conversation about the same branch.

If one of these is coming up and the current turn didn't clearly ask for it,
stop and ask instead of inferring permission from context, urgency, prior
turns, or "this is obviously what they want." This rule overrides any skill
step elsewhere that could otherwise be read as running to completion
unattended. It is intentionally kept here only, not copied into each skill
file, per this repo's general no-duplication rule (see "How To Use This
Repo").

## How To Use This Repo

- Use the skills in `.agents/skills/` for end-to-end agent workflows.
- Use the policies in `context/policies/` for reusable naming and writing
  standards.
- Prefer project-local rules, templates, hooks, and CI checks over these
  defaults when this workflow pack is installed into another repository.
- Keep guidance generic unless a file is intentionally project-specific.
- Do not duplicate policy details here; update the source policy or skill
  instead.

## Design Intent

orchraft is meant to be portable. The workflows should explain how an AI agent
ships and lands work safely without assuming a specific app stack, CI provider,
branch protection setup, or hosting platform.

The files here are defaults, not overrides. When copied into another project,
the target project's local instructions, PR templates, branch protections,
hooks, and CI checks should win.

## Skills

- `.agents/skills/ship/SKILL.md`: AI-driven branch, commit, push, and pull
  request creation/update workflow.
- `.agents/skills/land/SKILL.md`: AI-driven pull request landing workflow,
  including merge checks, local cleanup, and handoff.
- `.agents/skills/roast/SKILL.md`: AI-driven pull request review workflow
  that checks a PR against this repo's own policies and posts findings as a
  PR review with inline comments and a summary, CodeRabbit-style.
- `.claude/skills/ship/SKILL.md`, `.claude/skills/land/SKILL.md`, and
  `.claude/skills/roast/SKILL.md`: Claude skill symlinks so Claude sessions
  can use `/ship`, `/land`, and `/roast` while reading the same canonical
  skill files.

## Policies

- `context/policies/branch-policy.md`: branch name format, allowed types, and
  branch examples.
- `context/policies/commit-policy.md`: commit title/body format and required
  commit body sections.
- `context/policies/review-policy.md`: reviewer priority order, severity
  levels, and findings format for PR review.
- `context/policies/writing-guidelines.md`: shared writing rules, PR title/body
  defaults, secret hygiene, and project-template override guidance.

## Maintenance Notes

- Add workflow behavior to the relevant skill.
- Add reusable naming or writing rules to the relevant policy.
- Keep examples realistic and portable.
- When a policy and a project-local template disagree, the target project wins.
- Keep `CLAUDE.md` as a pointer to this file instead of duplicating these
  instructions.
- Keep Claude skills as symlinks to `.agents/skills`; edit the canonical skill
  files, not the links.

## What Not To Add Here

- Do not add project-specific build, test, deploy, or package commands.
- Do not duplicate full skill or policy contents.
- Do not duplicate tool-specific mirrors; use symlinks when a target tool
  requires another directory layout.
