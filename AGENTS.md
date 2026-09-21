# orchraft

orchraft automates the mundane, repetitive git/PR/issue chores of shipping
software — branch naming, commit hygiene, review, landing, status — built
first for solo developers with no one else to hand the busywork to. By
default the user approves every git, pull request, and issue mutation; the
one documented exception is the opt-in `Autonomous Mode` in
`context/policies/approval-policy.md`, off unless a repo owner writes it in.
The current skills cover planning, issues, pull requests, status, and
documentation (`warchief`, `watchtower`, `warplan`, `quest`, `ship`, `roast`,
`land`, `runes`, `reckoning`, `yap`, `lore`, `chronicle`); more workflows
will cover the rest of the lifecycle.
It is distributed as a Claude Code plugin and can also be copied into other
projects. Keep this file as the map, not the rulebook: detailed branch,
commit, PR, warplan, quest, ship, roast, land, runes, reckoning, yap, lore,
chronicle, warchief, and watchtower behavior lives in the files linked
below.

## Non-Negotiable: Ask Before Every Mutating Action

No commit, push, branch create/update, PR create/update/merge, or PR
comment/review happens without the user's explicit go-ahead in the current
turn, and approval never carries forward, unless a repo owner has written a
scoped `Autonomous Mode` opt-in into their own `approval-policy.md` naming
that exact action — and even then, merging, force-pushing, deleting, and
issue close/reopen stay gated regardless. The full rule lives in
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

- `.agents/skills/warplan/SKILL.md`: AI-driven planning workflow that drafts
  an implementation plan grounded in this repo's own conventions and
  precedent, before any code is written.
- `.agents/skills/quest/SKILL.md`: AI-driven issue triage, creation, and
  update workflow — the lifecycle stage before `ship`.
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
- `.agents/skills/lore/SKILL.md`: AI-driven workflow that adds or fixes code
  comments and docstrings across a diff, file, or PR to match
  `context/policies/lore-policy.md`, without committing or pushing.
- `.agents/skills/chronicle/SKILL.md`: AI-driven workflow that drafts or
  updates standalone Markdown docs — README sections, ROADMAP entries,
  design docs, feature write-ups — grounded in the real diff, code, commit
  history, or PR/issue text, per `context/policies/docs-policy.md`, without
  committing or pushing.
- `.agents/skills/runes/SKILL.md`: AI-driven status workflow that
  summarizes a branch's live state — its PR, checks, and unresolved `roast`
  findings — so the user doesn't have to re-explain where things stand.
  Read-only.
- `.agents/skills/reckoning/SKILL.md`: AI-driven status workflow that lists
  every review finding consciously declined rather than fixed, across the
  whole repo's pull requests (open, closed, and merged), by finding replies
  `ship` marked with `<!-- orchraft:declined -->`. Read-only.
- `.agents/skills/warchief/SKILL.md`: AI-driven orchestration workflow that
  chooses the next lifecycle role and hands off without weakening approval
  gates.
- `.agents/skills/watchtower/SKILL.md`: AI-driven read-only status nudge that
  surfaces actionable PR state without mutating git or GitHub.
- `.claude/skills/warplan/SKILL.md`, `.claude/skills/quest/SKILL.md`,
  `.claude/skills/ship/SKILL.md`, `.claude/skills/land/SKILL.md`,
  `.claude/skills/roast/SKILL.md`, `.claude/skills/runes/SKILL.md`,
  `.claude/skills/reckoning/SKILL.md`, `.claude/skills/yap/SKILL.md`,
  `.claude/skills/lore/SKILL.md`, `.claude/skills/chronicle/SKILL.md`,
  `.claude/skills/warchief/SKILL.md`, and
  `.claude/skills/watchtower/SKILL.md`: Claude skill symlinks so Claude
  sessions can use `/warplan`, `/quest`, `/ship`, `/land`, `/roast`,
  `/runes`, `/reckoning`, `/yap`, `/lore`, `/chronicle`, `/warchief`, and
  `/watchtower` while reading the same canonical skill files.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: Claude
  Code plugin manifest and single-plugin marketplace. The manifest's `skills`
  path points at `.agents/skills/`, so installed users get
  `/orchraft:warplan`, `/orchraft:quest`, `/orchraft:ship`, `/orchraft:land`,
  `/orchraft:roast`, `/orchraft:runes`, `/orchraft:reckoning`,
  `/orchraft:yap`, `/orchraft:lore`, `/orchraft:chronicle`,
  `/orchraft:warchief`, and `/orchraft:watchtower` from the same canonical
  files.
- `.codex-plugin/plugin.json`: Codex CLI plugin manifest, reading the same
  `.agents/skills/` files.
- `.grok-plugin/marketplace.json`: self-hosted marketplace listing for Grok
  Build, the same bypass-the-central-catalog mechanism Claude Code's own
  `.claude-plugin/marketplace.json` uses — separate from xAI's central
  `xai-org/plugin-marketplace` catalog, which needs its own PR to list
  orchraft there.

## Hooks

- `hooks/hooks.json`: declares a `SessionStart` hook (matched on
  `startup|resume|clear|compact`, never `fork` — Claude Code drops
  `additionalContext` silently on that source) that runs
  `hooks/watchtower-nudge.sh`, and a `PreToolUse` hook (matched on `Bash`)
  that runs `hooks/main-commit-nudge.sh`.
- `hooks/watchtower-nudge.sh`: a deterministic re-implementation of
  `watchtower`'s own surfacing rules in `bash`/`git`/`gh`, not a nested
  `claude -p` call — the rules are plain state checks (PR exists? checks
  failing? unresolved review threads? uncommitted local work?), not judgment
  calls, so a script covers them without the latency or cost of invoking the
  model again. It emits at most one `additionalContext` line, or none when
  there's nothing actionable. Degrades to a local-only nudge (or silence)
  when `gh` is missing or unauthenticated.
- `hooks/main-commit-nudge.sh`: nudges (never blocks — always
  `permissionDecision: allow`) when a `Bash` command is about to run `git
  commit` or `git push` while the current branch is the repository's
  default branch, the one bypass `ship`'s own Guardrails single out. The
  branch comes from `origin/HEAD`, falling back to `main`/`master` when no
  remote ref exists; it does not read `baseBranch`, which would need a
  second copy of `watchtower-nudge.sh`'s JSONC parsing. Deliberately scoped
  to that one branch, not every commit: a broader version would fire on
  `ship`'s own legitimate commits far more often than it would ever catch a
  real bypass, which is exactly the noise `watchtower-nudge.sh` is designed
  to avoid becoming.
- Both hook scripts require `jq` to parse their JSON stdin input and exit
  silently (not with an error) when it's missing — a missing soft
  dependency degrades to no nudge, never a failure the user has to notice.
- These are orchraft's only ambient (non-command-triggered) behaviors; every
  other skill still requires the user to invoke it.

## Evals

`evals/` holds `claude plugin eval` cases that check skill behavior rather than
file syntax. Each case is a prompt plus graders, run against the plugin and a
no-plugin baseline: `claude plugin eval . --case <name> --runs 1 --no-publish`.
Results land in `evals/results/`, which is git-ignored. Pass `--no-publish`
every time — without it, an account that supports report publishing uploads
the HTML report (prompts, transcripts, grader verdicts) to claude.ai by
default.

- Grade tool calls with `tool_used`, not a `regex` over the trace — the trace
  contains the skill's own text, so a regex for something like `git merge`
  matches the instructions instead of an action.
- Keep prompts in natural language. A bare `/roast` does not invoke the skill
  in a child session.
- A case that needs a repository ships a `case.yaml` with a
  `context.scaffold_script`; it runs only under `--scaffold`, and non-read-only
  tools need `--allow-tools Bash Edit Write` on the command line:
  `claude plugin eval . --case ship-requires-request --runs 1 --scaffold
  --allow-tools Bash Edit Write --no-publish`.
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
- `context/policies/config-policy.md`: the optional `.orchraft.jsonc` (or
  `.orchraft.json`) a target repo can add for fixed choices such as merge
  method, and how it ranks against platform constraints and the prose
  policies.
- `context/policies/lore-policy.md`: language-agnostic rules for when to
  write a code comment or docstring (lore), and the shape it should take.
- `context/policies/docs-policy.md`: rules for when to draft or update a
  standalone Markdown doc, how every claim must be grounded in a real
  source, and the shape and tone it should take.
- `context/policies/review-policy.md`: reviewer priority order, severity
  levels, and findings format for PR review.
- `context/policies/verification-policy.md`: what counts as validation before
  a change is reported ready to ship or land, how to report results honestly,
  and edge cases like flaky or pre-existing failures.
- `context/policies/writing-guidelines.md`: shared writing rules, PR title/body
  defaults, secret hygiene, and project-template override guidance.

## Maintenance Notes

- Add workflow behavior to the relevant skill.
- Add reusable naming or writing rules to the relevant policy.
- When adding or removing a skill, `.agents/skills/` is the inventory and
  every doc that restates it has to follow. `grep -rn watchtower *.md` finds
  the rosters, since each one names every skill; the skill-count badge in
  `README.md` holds a number rather than names, so check it separately.
  Nothing enforces either — `reckoning` reached `main` missing from
  `CONTRIBUTING.md`.
- The same applies to policies: `context/policies/` is the inventory, and
  `grep -rn commit-policy *.md` finds the docs that list them by filename.
  `README.md`'s Layout entry names them in prose instead, so a filename
  search misses it — check that one by eye.
- A new config setting goes in three places in the same change:
  `context/policies/config-policy.md`, which documents it;
  `.orchraft.example.jsonc`, which is supposed to show every field; and a
  consumer that actually reads it —
  `grep -rn <key> .agents/skills/ hooks/ context/policies/` should name one.
  A setting nothing reads silently does nothing while the docs promise
  otherwise; that shipped twice on the branch that added the config file.
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
