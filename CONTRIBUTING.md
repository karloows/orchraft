# Contributing to orchraft

Thanks for considering a contribution. orchraft is a Claude Code plugin —
Markdown skills and policies plus a couple of shell hooks — so most
contributions are documentation-shaped, not code-shaped. This guide walks
through the whole repo so you don't have to reconstruct it from source.

Read [`AGENTS.md`](AGENTS.md) too — it's the canonical map this file
summarizes, and it wins if the two ever disagree.

## What's in this repo

### Skills (`.agents/skills/<name>/SKILL.md`)

Each skill is a self-contained workflow the user invokes explicitly (except
`watchtower`, see Hooks below). These are the skills that ship today:

| Skill | Stage | What it does |
| --- | --- | --- |
| `warplan` | plan | Drafts an implementation plan grounded in this repo's own conventions and precedent, before code is written. |
| `quest` | issue | Triages, creates, or updates a GitHub issue. |
| `ship` | branch/commit/PR | Creates a policy-compliant branch, commit, push, and pull request from the actual diff. |
| `roast` | review | Reviews a PR against this repo's own policies and posts findings as a PR review with inline comments. |
| `land` | merge | Checks mergeability and CI, merges with the repo's default method, syncs `main`, cleans up the branch. |
| `yap` | explain | Explains a PR/diff, file, error/log, policy, or dependency, citing real sources. Read-only. |
| `lore` | comments | Adds or fixes code comments/docstrings across a diff, file, or PR. Doesn't commit or push. |
| `chronicle` | docs | Drafts or updates standalone Markdown docs (README sections, design docs, ROADMAP entries). Doesn't commit or push. |
| `runes` | status | Summarizes a branch's live state: PR, checks, unresolved `roast` findings. Read-only. |
| `warchief` | orchestration | Chooses the next lifecycle step and hands off, without performing mutations itself. |
| `watchtower` | status nudge | Surfaces a short read-only nudge about actionable PR state. |

Each skill's file is a single Markdown document with YAML frontmatter
(`name`, `description`) that Claude Code uses to decide when to trigger it,
followed by the workflow instructions themselves.

`.claude/skills/<name>/SKILL.md` are symlinks to the files above, so a
Claude Code session sees `/orchraft:<name>` (or `/<name>` when installed
directly into a project). **Always edit the canonical file under
`.agents/skills/`** — never break a symlink by replacing it with a real
file.

### Policies (`context/policies/*.md`)

Shared, reusable rules that multiple skills read rather than each
reimplementing:

| Policy | Covers |
| --- | --- |
| `approval-policy.md` | Which git/PR/issue actions need the user's current-turn go-ahead, and the opt-in `Autonomous Mode` exception. |
| `branch-policy.md` | Branch name format (`<type>/<short-kebab-description>`), allowed conventional-commit types, examples. |
| `commit-policy.md` | Commit title format (Conventional Commits), when to add a body, footer rules. |
| `lore-policy.md` | Language-agnostic rules for when a code comment/docstring is warranted and what shape it takes. |
| `docs-policy.md` | When to draft/update a standalone Markdown doc, sourcing every claim, tone and shape. |
| `review-policy.md` | Reviewer priority order, severity levels, findings format for PR review. |
| `verification-policy.md` | What counts as validation before a change is reported ready to ship/land; honest reporting; flaky/pre-existing failures. |
| `writing-guidelines.md` | Shared writing rules, PR title/body defaults, secret hygiene, project-template override precedence. |

Skills read `context/policies/<file>` from the *target* repo first, falling
back to the copy bundled with the plugin — so a project that installs
orchraft can override any policy locally without forking it.

`context/personality.md` defines the orc voice, but its use is deliberately
narrow: user-facing surfaces only (README intro, plugin descriptions, skill
handoff lines). Policies, commit messages, and PR text stay plain — don't
add orc flavor to those.

### Hooks (`hooks/`)

- `hooks/hooks.json` declares a `SessionStart` hook (matched on
  `startup|resume|clear|compact`, deliberately never `fork`) that runs
  `hooks/watchtower-nudge.sh`.
- `hooks/watchtower-nudge.sh` is a deterministic `bash`/`git`/`gh`
  reimplementation of `watchtower`'s surfacing rules — not a nested `claude
  -p` call, since the checks (PR exists? checks failing? unresolved review
  threads? uncommitted local work?) are plain state checks, not judgment
  calls. It emits at most one `additionalContext` line, or none when
  there's nothing actionable, and degrades to a local-only nudge (or
  silence) when `gh` is missing or unauthenticated.
- This hook is orchraft's *only* ambient behavior. Every other skill
  requires explicit invocation — don't add a second one without strong
  justification, since it works against the "nothing touches git/GitHub
  until you say go" promise in the README.

### Evals (`evals/`)

`claude plugin eval` cases that check skill *behavior* (does the skill call
the tools it should, in the right circumstances) rather than file syntax.
Each case is a prompt plus graders, run against the plugin and a no-plugin
baseline. See "Testing a skill change" below for how to run them, and
`evals/` for the existing cases (`land-without-pr`,
`lore-no-git-mutation`, `roast-without-pr`, `ship-requires-request`) as
templates for new ones.

### Plugin manifest (`.claude-plugin/`)

`plugin.json` and `marketplace.json` are the Claude Code plugin manifest
and single-plugin marketplace. `plugin.json`'s `skills` field points at
`.agents/skills/`, so installed users get `/orchraft:warplan` etc. from the
same canonical files described above. Don't hand-edit `plugin.json`'s
`version` — `release-please` bumps it alongside `package.json`.

## Design intent

orchraft is meant to be portable: the workflows should explain how an
agent ships, reviews, lands, and explains work safely without assuming a
specific app stack, CI provider, branch-protection setup, or hosting
platform. Policies and skills here are *defaults*, not overrides — when
orchraft is copied into another project, that project's local
instructions, PR templates, branch protections, hooks, and CI checks should
win. Keep that in mind for every change: prefer generic guidance, and don't
bake in assumptions specific to this repo's own setup.

## Making a change

- **New or changed skill behavior** goes in the relevant
  `.agents/skills/<name>/SKILL.md`.
- **New or changed reusable naming/writing rules** go in
  `context/policies/`. If a rule is skill-specific but still reusable,
  check the policy table above before adding a new file — it likely
  belongs in an existing one.
- **Every mutating action** (commit, push, branch, PR, issue) stays gated
  behind `context/policies/approval-policy.md`. Don't write a skill step
  that could be read as running one to completion unattended; the policy
  overrides any step that implies otherwise.
- Don't duplicate policy or skill content into `AGENTS.md` — it's a
  pointer file. Update the source policy or skill instead, and keep
  `AGENTS.md`'s summary in sync if the change affects what it lists.
- Don't add project-specific build/test/deploy/package commands anywhere in
  this repo's own instructions, and don't duplicate tool-specific mirrors —
  use a symlink (like `.claude/skills/`) when a target tool needs a
  different directory layout.

## Testing a skill change

Skill behavior is checked with `claude plugin eval`, not a unit test suite:

```
claude plugin eval . --case <name> --runs 1 --no-publish
```

- Always pass `--no-publish` — without it, an account that supports report
  publishing uploads the HTML report (prompts, transcripts, grader
  verdicts) to claude.ai by default. Results otherwise land in
  `evals/results/`, which is git-ignored.
- Grade tool calls with `tool_used`, not a `regex` over the trace — the
  trace contains the skill's own instructional text, so a regex like `git
  merge` can match the instructions instead of an actual action.
- Keep eval prompts in natural language. A bare `/roast` does not invoke
  the skill in a child session.
- A case that needs a repository ships a `case.yaml` with a
  `context.scaffold_script`; it only runs under `--scaffold`, and
  non-read-only tools need `--allow-tools Bash Edit Write` on the command
  line, e.g.:

  ```
  claude plugin eval . --case ship-requires-request --runs 1 --scaffold \
    --allow-tools Bash Edit Write --no-publish
  ```

- Granting `Bash` needs a sandbox the runner can seal. It refuses on a
  machine whose Docker credential store holds symlinks — the default
  Docker Desktop layout on macOS — so run those cases where that store is
  absent.

## Trying a skill change locally

To see a skill's behavior change reflected in a live Claude Code session
before opening a PR, install the plugin from your local checkout (Claude
Code supports adding a local path as a marketplace source) and invoke the
skill by name, or just point a session at this repo and ask it to run the
skill — either way it reads the same `.agents/skills/` files you edited.

## Commit and branch conventions

Follow `context/policies/commit-policy.md` (Conventional Commits:
`<type>(<scope>): <summary>`, body only when the title alone would leave a
reviewer guessing why) and `context/policies/branch-policy.md`
(`<type>/<short-kebab-description>`, max three words after the slash) for
your own commits and branches in this repo — the same rules the workflows
here would generate for you. Never commit or push directly to `main`.

## Pull requests

- Keep PRs scoped to one skill or policy where possible.
- `.github/PULL_REQUEST_TEMPLATE.md` fills in automatically when you open a
  PR — fill it out rather than deleting it.
- Describe *why* the change is needed, not just what changed — reviewers
  will check the PR against `context/policies/review-policy.md`'s priority
  order and severity levels.
- Follow `context/policies/writing-guidelines.md` for PR title/body tone:
  concise, technical, active voice, no marketing language or emojis, no
  secrets or tokens in the PR text.
- If you're adding a new skill, update the skill table in `README.md` and
  the skill list in `AGENTS.md` in the same PR — both currently describe
  the exact same eleven skills above, and they'll drift if only one is
  updated.
- If you're adding a new policy, list it in `AGENTS.md`'s Policies section
  too.

## Code of conduct and security

- This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
- Report security vulnerabilities privately per [`SECURITY.md`](SECURITY.md)
  — not as a public issue.

## License

Apache-2.0 (see `LICENSE`). By contributing, you agree your contribution is
licensed under the same terms.
