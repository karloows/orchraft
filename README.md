# Orchraft

**Orchestration, crafted by orcs.**

We are a clan of orcs who craft and orchestrate the software development
lifecycle for AI coding agents. Our work is to carry a change from first idea
to merged code with discipline: your repo's rules, real sources behind every
claim, and nothing touches git or GitHub until you, the chief, say go.

The name joins *orchestration* and *craft*. The orc does the crafting.

## Clan Laws

- **The chief decides.** No commit, push, merge, or PR comment happens without
  your go-ahead in the current turn (`context/policies/approval-policy.md`).
- **Your stronghold, your rules.** We read your project's policies, templates,
  and CI config first. Our bundled policies are only defaults.
- **No bluffing.** Branch names, commits, reviews, and explanations come from
  the real diff, history, and docs.
- **Any stack.** No assumptions about language, CI provider, or hosting.

## The War Band So Far

Each skill is one tool in the clan's kit. These are forged today; more are on
the anvil as we cover the rest of the lifecycle.

| Skill | What it does |
| --- | --- |
| `ship` | Creates a policy-compliant branch, commit, push, and pull request from the actual diff. |
| `roast` | Reviews the pull request against your repo's policies and posts findings as inline comments with fixes and copy-paste AI prompts. |
| `land` | Checks mergeability and CI, merges with the repo's default method, syncs `main`, and cleans up the branch. |
| `yap` | Explains a PR, file, error, policy, or dependency, citing real sources instead of guessing. Read-only. |

Today's march is `ship` → `roast` → fix → `ship` → `land`, with `yap`
available at any point.

## Status

Early (0.x). The forge is hot: skill behavior and policy formats may still
change between releases.

## Layout

- `.agents/skills/`: canonical agent skills.
- `.claude/skills/`: Claude skill symlinks for `/ship`, `/land`, `/roast`, and
  `/yap`.
- `.claude-plugin/`: Claude Code plugin manifest and marketplace.
- `context/policies/`: reusable approval, branch, commit, review, and PR
  writing policies.
- `context/personality.md`: the orc's character and voice, and where it
  applies.

Edit the canonical skill files in `.agents/skills/`; the Claude skill files are
symlinks.

## Install As A Claude Code Plugin

```shell
/plugin marketplace add karloows/orchraft
/plugin install orchraft@orchraft
```

If the install reports that the plugin isn't active yet, run
`/reload-plugins` (or `/reload-plugins --force` if it warns about the prompt
cache).

The skills load as `/orchraft:ship`, `/orchraft:land`, `/orchraft:roast`, and
`/orchraft:yap`. They read `context/policies/` from your repo when present
and fall back to the policies bundled with the plugin.

To try a local checkout without installing, run
`claude --plugin-dir /path/to/orchraft`.

## Copy Into A Project

For other agents, or to customize the files, copy the parts you need into a
target project:

- `.agents/skills/` for the canonical `ship`, `land`, `roast`, and `yap`
  workflows.
- `context/policies/` for approval, branch, commit, review, and PR writing
  rules.
- `context/personality.md` for the orc voice the skills use in success lines.
- `.claude/skills/` when using Claude Code and you want `/ship`, `/land`,
  `/roast`, and `/yap`.

Copy `context/` together with the skills. The skills fall back to
`${CLAUDE_PLUGIN_ROOT}/context/` only when running as the plugin; outside it,
that path doesn't resolve.

Project-local instructions, PR templates, hooks, and CI checks should override
these defaults.

## Releases

Versioning and `CHANGELOG.md` are managed by
[release-please](https://github.com/googleapis/release-please). Merge a
release PR to publish a new version; do not edit `CHANGELOG.md` by hand.

## License

Apache-2.0
