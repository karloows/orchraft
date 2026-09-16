# orchraft

orchraft orchestrates the software development lifecycle for AI coding
agents, with the user approving every mutating step. The current skills cover
pull requests (`ship`, `roast`, `land`, `yap`); more workflows will cover the
rest of the lifecycle. It is distributed as a Claude Code plugin and can also
be copied into other projects. Keep this file as the map, not the rulebook:
detailed branch, commit, PR, ship, roast, land, and yap behavior lives in the
files linked below.

## Non-Negotiable: Ask Before Every Mutating Action

No commit, push, branch create/update, PR create/update/merge, or PR
comment/review happens without the user's explicit go-ahead in the current
turn, and approval never carries forward. The full rule lives in
`context/policies/approval-policy.md` so it ships with the plugin; read it
before any of those actions. It overrides any skill step that could be read
as running to completion unattended.

## How To Use This Repo

- Use the skills in `.agents/skills/` for end-to-end agent workflows.
- Use the policies in `context/policies/` for reusable naming and writing
  standards.
- Use `context/personality.md` for the orc voice on user-facing surfaces
  (README intro, plugin descriptions, skill handoff lines). Everything that
  file excludes, including policies, commits, and PR text, stays plain.
- Prefer project-local rules, templates, hooks, and CI checks over these
  defaults when this workflow pack is installed into another repository.
- Keep guidance generic unless a file is intentionally project-specific.
- Do not duplicate policy details here; update the source policy or skill
  instead.

## Design Intent

orchraft is meant to be portable. The workflows should explain how an AI agent
ships, reviews, lands, and explains work safely without assuming a specific
app stack, CI provider, branch protection setup, or hosting platform.

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
- `.agents/skills/yap/SKILL.md`: AI-driven explainer workflow that explains a
  PR/diff, file, error/log, policy, or dependency grounded in real sources
  (code, git history, docs) with citations, read-only.
- `.claude/skills/ship/SKILL.md`, `.claude/skills/land/SKILL.md`,
  `.claude/skills/roast/SKILL.md`, and `.claude/skills/yap/SKILL.md`: Claude
  skill symlinks so Claude sessions can use `/ship`, `/land`, `/roast`, and
  `/yap` while reading the same canonical skill files.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: Claude
  Code plugin manifest and single-plugin marketplace. The manifest's `skills`
  path points at `.agents/skills/`, so installed users get `/orchraft:ship`,
  `/orchraft:land`, `/orchraft:roast`, and `/orchraft:yap` from the same
  canonical files.

## Evals

`evals/` holds `claude plugin eval` cases that check skill behavior rather than
file syntax. Each case is a prompt plus graders, run against the plugin and a
no-plugin baseline: `claude plugin eval . --case <name> --runs 1`. Results land
in `evals/results/`, which is git-ignored.

- Grade tool calls with `tool_used`, not a `regex` over the trace — the trace
  contains the skill's own text, so a regex for something like `git merge`
  matches the instructions instead of an action.
- Keep prompts in natural language. A bare `/roast` does not invoke the skill
  in a child session.
- A case that needs a repository ships a `case.yaml` with a
  `context.scaffold_script`; it runs only under `--scaffold`, and non-read-only
  tools need `--allow-tools Bash Edit Write` on the command line:
  `claude plugin eval . --case ship-requires-request --runs 1 --scaffold
  --allow-tools Bash Edit Write`.
- Granting Bash needs a sandbox the runner can seal. It refuses on a machine
  whose Docker credential store holds symlinks, which is the default Docker
  Desktop layout on macOS, so run those cases where that store is absent.

## Policies

Skills read `context/policies/<file>` from the target repo when it exists,
falling back to the copy bundled with the plugin.

- `context/policies/approval-policy.md`: which git and PR actions need the
  user's current-turn go-ahead, and why approval never carries forward.
- `context/policies/branch-policy.md`: branch name format, allowed types, and
  branch examples.
- `context/policies/commit-policy.md`: commit title format and when to add a
  free-form prose body.
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
- Don't edit the plugin manifest's `version` by hand; release-please bumps it
  alongside `package.json`.

## What Not To Add Here

- Do not add project-specific build, test, deploy, or package commands.
- Do not duplicate full skill or policy contents.
- Do not duplicate tool-specific mirrors; use symlinks when a target tool
  requires another directory layout.
