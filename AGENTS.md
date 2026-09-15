# orchraft

orchraft contains reusable agent workflow guidance that can be copied
into other projects. Keep this file as the map, not the rulebook: detailed
branch, commit, PR, ship, and land behavior lives in the files linked below.

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
- `.agents/skills/review/SKILL.md`: AI-driven pull request review workflow
  that checks a PR against this repo's own policies and posts findings as a
  PR review with inline comments and a summary, CodeRabbit-style.
- `.claude/skills/ship/SKILL.md`, `.claude/skills/land/SKILL.md`, and
  `.claude/skills/review/SKILL.md`: Claude skill symlinks so Claude sessions
  can use `/ship`, `/land`, and `/review` while reading the same canonical
  skill files.

## Policies

- `context/policies/branch-policy.md`: branch name format, allowed types, and
  branch examples.
- `context/policies/commit-policy.md`: commit title/body format and required
  commit body sections.
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
