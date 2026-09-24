# orchraft

orchraft automates the mundane, repetitive git/PR/issue chores of shipping
software — branch naming, commit hygiene, review, landing, status — built
first for solo developers with no one else to hand the busywork to. By
default the user approves every git, pull request, issue, and release
mutation; the one documented exception is the opt-in `Autonomous Mode` in
`context/policies/approval-policy.md`, off unless a repo owner writes it in.
The current skills cover planning, issues, pull requests, status,
documentation, and release notes (`warchief`, `watchtower`, `warplan`,
`quest`, `ship`, `roast`, `land`, `runes`, `reckoning`, `plunder`,
`muster`, `yap`, `lore`, `chronicle`, `herald`); more workflows will cover
the rest of the lifecycle.
It is distributed as a Claude Code plugin and can also be copied into other
projects. Keep this file as the map, not the rulebook: detailed branch,
commit, PR, warplan, quest, ship, roast, land, runes, reckoning,
plunder, muster, yap, lore, chronicle, herald, warchief, and watchtower
behavior lives in the files linked below.

## Non-Negotiable: Ask Before Every Mutating Action

No commit, push, branch create/update, PR create/update/merge, PR
comment/review, issue change, or release create/edit happens without the
user's explicit go-ahead in the current turn, and approval never carries
forward, unless a repo owner has written a scoped `Autonomous Mode` opt-in
into their own `approval-policy.md` naming that exact action — and even then,
merging, force-pushing, deleting, and issue close/reopen stay gated
regardless. The full rule lives in `context/policies/approval-policy.md` so it
ships with the plugin; read it before any of those actions. It overrides any
skill step that could be read as running to completion unattended.

## How To Use This Repo

- Use the skills in `skills/` for end-to-end agent workflows.
- Use the policies in `context/policies/` for reusable naming and writing
  standards.
- Use `context/personality.md` for the orc voice on user-facing surfaces
  (README intro, plugin descriptions, skill handoff lines). Everything that
  file excludes, including policies, commits, PR text, and release notes,
  stays plain.
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

- `skills/warplan/SKILL.md`: AI-driven planning workflow that drafts
  an implementation plan grounded in this repo's own conventions and
  precedent, before any code is written.
- `skills/quest/SKILL.md`: AI-driven issue triage, creation, and
  update workflow — the lifecycle stage before `ship`.
- `skills/ship/SKILL.md`: AI-driven branch, commit, push, and pull
  request creation/update workflow.
- `skills/land/SKILL.md`: AI-driven pull request landing workflow,
  including merge checks, local cleanup, and handoff.
- `skills/roast/SKILL.md`: AI-driven pull request review workflow
  that checks a PR against this repo's own policies and posts findings as a
  PR review with inline comments and a summary, CodeRabbit-style.
- `skills/yap/SKILL.md`: AI-driven explainer workflow that explains a
  PR/diff, file, error/log, policy, or dependency grounded in real sources
  (code, git history, docs) with citations, read-only.
- `skills/lore/SKILL.md`: AI-driven workflow that adds or fixes code
  comments and docstrings across a diff, file, or PR to match
  `context/policies/lore-policy.md`, without committing or pushing.
- `skills/chronicle/SKILL.md`: AI-driven workflow that drafts or
  updates standalone Markdown docs — README sections, ROADMAP entries,
  design docs, feature write-ups — grounded in the real diff, code, commit
  history, or PR/issue text, per `context/policies/docs-policy.md`, without
  committing or pushing.
- `skills/runes/SKILL.md`: AI-driven status workflow that
  summarizes a branch's live state — its PR, checks, and unresolved `roast`
  findings — so the user doesn't have to re-explain where things stand.
  Read-only.
- `skills/reckoning/SKILL.md`: AI-driven status workflow that lists
  every review finding consciously declined rather than fixed, across the
  whole repo's pull requests (open, closed, and merged), by finding replies
  `ship` marked with `<!-- orchraft:declined -->`. Read-only.
- `skills/plunder/SKILL.md`: AI-driven status workflow that reports
  real repo-wide shipping signal — PRs opened, `roast` findings caught and
  their fixed/declined/open fate, and time-to-land — grounded in live
  git/GitHub history rather than an invented benchmark score. Read-only.
- `skills/muster/SKILL.md`: AI-driven status workflow that reports
  actionable open-PR state (failing/pending checks, merge conflicts,
  unresolved review threads) across every repo the connected account
  personally owns, not just the current one. Read-only.
- `skills/herald/SKILL.md`: AI-driven release-notes workflow that
  drafts notes from the pull requests merged in a release's range, plus any
  commit that reached the base branch without one, cited by short SHA, and,
  on the user's go-ahead, writes them into the GitHub release. Never edits
  `CHANGELOG.md`, which release tooling owns.
- `skills/warchief/SKILL.md`: AI-driven orchestration workflow that
  chooses the next lifecycle role and hands off without weakening approval
  gates.
- `skills/watchtower/SKILL.md`: AI-driven read-only status nudge that
  surfaces actionable PR state without mutating git or GitHub.
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: Claude
  Code plugin manifest and single-plugin marketplace. The manifest declares
  no `skills` field — `skills/` at the repo root is the default component
  directory Claude Code scans without one, so installed users get
  `/orchraft:warplan`, `/orchraft:quest`, `/orchraft:ship`, `/orchraft:land`,
  `/orchraft:roast`, `/orchraft:runes`, `/orchraft:reckoning`,
  `/orchraft:plunder`, `/orchraft:muster`, `/orchraft:yap`,
  `/orchraft:lore`, `/orchraft:chronicle`, `/orchraft:herald`,
  `/orchraft:warchief`, and `/orchraft:watchtower` from the same canonical
  files.
- `.codex-plugin/plugin.json`: Codex CLI plugin manifest. Declares no
  `skills` field either — under the real Agent Plugins 1.0.0 schema it
  targets (agent-plugins.org/schemas/1.0.0/plugin.schema.json), `skills`
  isn't a valid manifest property at all; component discovery is pure
  `skills/` directory convention, the same one Claude Code, Grok Build, and
  Devin scan.
- `plugin.json` (repo root): the current-preferred Agent Plugins 1.0.0
  manifest location, alongside `.codex-plugin/plugin.json` rather than
  replacing it — real, credible plugins (Sanity, Resend,
  `gemini-cli-extensions/postgres`) ship this exact root file with the same
  `$schema`, and none of the ones checked removed their legacy-path copy
  either. Read by any Agent-Plugins-compliant host. Note:
  `gemini-cli-extensions/postgres` ships this `plugin.json` *alongside* a
  separate `gemini-extension.json` with its own distinct schema — that
  second file, not `plugin.json`, is Gemini CLI's own native manifest;
  don't assume Gemini CLI reads this format directly. Keep its `version` in
  sync via `release-please-config.json`'s `extra-files`, same as the other
  two manifests.
- `.grok-plugin/marketplace.json`: self-hosted marketplace listing for Grok
  Build, the same bypass-the-central-catalog mechanism Claude Code's own
  `.claude-plugin/marketplace.json` uses — separate from xAI's central
  `xai-org/plugin-marketplace` catalog, which needs its own PR to list
  orchraft there.
- `.cursor-plugin/plugin.json` and `.cursor-plugin/marketplace.json`: Cursor
  plugin manifest and self-hosted marketplace listing, installed via
  Cursor's **Customize → From GitHub Repository** GUI, or via the
  `cursor-agent` CLI's interactive `/plugin` slash command — unlike
  Claude Code/Codex/Grok Build, there's no scriptable one-line install
  command for either. Unlike Codex's pure
  directory-convention discovery, Cursor's `plugin.json` schema declares an
  explicit `"skills": "./skills/"` field pointing at the same canonical
  `skills/` directory this repo already uses — confirmed against two real
  manifests in `cursor/plugins` (`teaching`, `create-plugin`), both of
  which declare `skills`/`category` the same way. Still no directory
  restructuring needed, just the one explicit field. **Not yet verified
  live**: unlike every other ecosystem entry in this file, this hasn't been
  installed into a real Cursor app and checked for a full 15-skill catalog
  — say so if you ever confirm or refute it live.
- Devin (Devin Desktop, formerly Windsurf, and the Devin CLI) needs no new
  manifest: it checks `.devin-plugin/plugin.json`, then
  `.claude-plugin/plugin.json`, then root `plugin.json`, so it picks up
  `.claude-plugin/plugin.json`, loads root `skills/`, and exposes them as
  `/orchraft:<skill>` after `devin plugins install karloows/orchraft`.
  Devin also injects this file into every session of every project where
  the plugin is installed — a plugin-root `AGENTS.md` is always-on and no
  manifest field disables it — so anything written here reaches Devin
  users, not just contributors. Devin's docs don't say whether it runs
  `hooks/hooks.json` for a Claude-format plugin. **Not yet verified live**,
  same caveat as Cursor.
- Zed: orchraft ships no Zed extension or install path, so users copy
  skills into their own project's `.agents/skills/` and `context/` into
  the project root, as README's Copy Into A Project describes. The Zed
  Agent reads a project's root `AGENTS.md`, so this file only reaches
  contributors with this repo open, and only while it is the first match
  in Zed's
  instruction-file list (`.rules`, `.cursorrules`, `.windsurfrules`,
  `.clinerules`, `.github/copilot-instructions.md`, `AGENT.md`,
  `AGENTS.md`, `CLAUDE.md`) — adding any file earlier in that list would
  replace it. External agents run inside Zed (Claude Code, Codex, Gemini
  CLI) use their own instruction files and plugin installs, not Zed's
  loader.

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
- When adding or removing a skill, `skills/` is the inventory and
  every doc that restates it has to follow. `grep -rn watchtower *.md` finds
  the rosters, since each one names every skill; the skill-count badge in
  `README.md` holds a number rather than names, so check it separately.
  Nothing enforces either — `reckoning` reached `main` missing from
  `CONTRIBUTING.md`.
- The same applies to policies: `context/policies/` is the inventory, and
  `grep -rn commit-policy *.md` finds the docs that list them by filename.
  `README.md`'s Layout entry names them in prose instead, so a filename
  search misses it — check that one by eye.
- A new config setting, or a change to what an existing one means, goes in
  three places in the same change:
  `context/policies/config-policy.md`, which documents it;
  `.orchraft.example.jsonc`, which is supposed to show every field; and a
  consumer that actually reads it —
  `grep -rn <key> skills/ hooks/ context/policies/` should name a
  file that reads it as a setting. `config-policy.md` doesn't count, since
  it defines every key, and neither does prose that only uses the word, as
  many files do with "validate".
  A setting nothing reads silently does nothing while the docs promise
  otherwise; that shipped twice on the branch that added the config file.
- Keep examples realistic and portable.
- When a policy and a project-local template disagree, the target project wins.
- Keep `CLAUDE.md` as a pointer to this file instead of duplicating these
  instructions.
- Skills live only in `skills/` — Claude Code, Codex, Grok Build, Devin, and
  (as a packaged plugin) Cursor all read it directly, so there is no
  per-ecosystem symlink layer to keep in sync.
- Don't edit the plugin manifest's `version` by hand; release-please bumps it
  alongside `package.json`.

## What Not To Add Here

- Do not add project-specific build, test, deploy, or package commands.
- Do not duplicate full skill or policy contents.
- Do not duplicate tool-specific mirrors, and do not reach for a symlink to
  paper over a directory-layout mismatch — `skills/` at the repo root is the
  one shared convention every supported tool already scans by default.
