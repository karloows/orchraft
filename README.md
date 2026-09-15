# Orchraft

A toolkit for building and orchestrating agentic software development workflows with reusable agents, skills, rules, and automation.

## Status

Orchraft is in early setup.

## Layout

- `.agents/skills/`: canonical agent skills.
- `.claude/skills/`: Claude skill symlinks for `/ship`, `/land`, `/roast`, and
  `/yap`.
- `context/policies/`: reusable branch, commit, and PR writing policies.

Edit the canonical skill files in `.agents/skills/`; the Claude skill files are
symlinks.

## Usage

Copy the parts you need into a target project:

- `.agents/skills/` for the canonical `ship`, `land`, `roast`, and `yap`
  workflows.
- `context/policies/` for branch, commit, and PR writing rules.
- `.claude/skills/` when using Claude Code and you want `/ship`, `/land`,
  `/roast`, and `/yap`.

Project-local instructions, PR templates, hooks, and CI checks should override
these defaults.

## Releases

Versioning and `CHANGELOG.md` are managed by
[release-please](https://github.com/googleapis/release-please). Merge a
release PR to publish a new version; do not edit `CHANGELOG.md` by hand.

## License

Apache-2.0
