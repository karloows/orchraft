# Orchraft

**Orchestration, crafted by orcs.**

We are a clan of orcs who haul the mundane, repetitive chores of shipping
software off your plate — branch names, commit messages, PR write-ups,
review nits, remembering what's still open — the stuff every developer does
by hand every single time and nobody looks forward to, so the chief can
spend the saved hours on the code that's actually interesting. Built first
for the solo dev with no one else to hand the busywork to, welcome at any war
table: your repo's rules, real sources behind every claim, and nothing
touches git or GitHub until you say go.

The name joins *orchestration* and *craft*. The orc does the crafting.

## Clan Laws

- **The chief decides.** No commit, push, merge, or PR comment happens without
  your go-ahead in the current turn, by default
  (`context/policies/approval-policy.md`). Opt into `Autonomous Mode` there if
  you want routine mutations pre-authorized — merge, force-push, delete, and
  issue close/reopen stay gated either way.
- **Your stronghold, your rules.** We read your project's policies, templates,
  and CI config first. Our bundled policies are only defaults.
- **No bluffing.** Branch names, commits, reviews, and explanations come from
  the real diff, history, and docs.
- **Any stack.** No assumptions about language, CI provider, or hosting.

## The War Band So Far

Each skill is one tool in the clan's kit. These are forged today; more are on
the anvil as we cover the rest of the lifecycle.

| Skill | Clan role | What it does |
| --- | --- | --- |
| `ship` | 🚢 Raid Captain | Creates a policy-compliant branch, commit, push, and pull request from the actual diff. |
| `roast` | 🔥 Trialmaster | Reviews the pull request against your repo's policies and posts findings as inline comments with fixes and copy-paste AI prompts. |
| `land` | 🏰 Haulmaster | Checks mergeability and CI, merges with the repo's default method, syncs `main`, and cleans up the branch. |
| `yap` | 🗣️ Scout | Explains a PR, file, error, policy, or dependency, citing real sources instead of guessing. Read-only. |
| `lore` | 📜 Loremaster | Adds or fixes code comments and docstrings across a diff, file, or PR to match your repo's lore policy. |
| `runes` | 📖 Rune-Reader | Summarizes the live state of a branch, PR, checks, and standing review findings. Read-only. |
| `warchief` | War Council | Chooses the next lifecycle role without treating orchestration as approval for mutations. |
| `watchtower` | Watchtower | Surfaces a short read-only nudge about actionable PR state. |

Today's march is `lore` → `ship` → `roast` → fix → `ship` → `land`, with `yap`
available at any point.

## Status

Early (0.x). The forge is hot: skill behavior and policy formats may still
change between releases.

## Layout

- `.agents/skills/`: canonical agent skills.
- `.claude/skills/`: Claude skill symlinks for `/ship`, `/land`, `/roast`,
  `/yap`, `/lore`, `/runes`, `/warchief`, and `/watchtower`.
- `.claude-plugin/`: Claude Code plugin manifest and marketplace.
- `hooks/`: a `SessionStart` hook that runs `watchtower`'s status checks
  automatically (a plain script, not a model call) so the nudge shows up
  without asking for it. The only ambient behavior here — every other skill
  is invoked on purpose.
- `context/policies/`: reusable approval, branch, commit, lore, review, and PR
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

The skills load as `/orchraft:ship`, `/orchraft:land`, `/orchraft:roast`,
`/orchraft:yap`, `/orchraft:lore`, `/orchraft:runes`, `/orchraft:warchief`,
and `/orchraft:watchtower`. They read `context/policies/` from your repo when
present and fall back to the policies bundled with the plugin.

To try a local checkout without installing, run
`claude --plugin-dir /path/to/orchraft`.

## Copy Into A Project

For other agents, or to customize the files, copy the parts you need into a
target project:

- `.agents/skills/` for the canonical `ship`, `land`, `roast`, `yap`, `lore`,
  `runes`, `warchief`, and `watchtower` workflows.
- `context/policies/` for approval, branch, commit, lore, review, and PR
  writing rules.
- `context/personality.md` for the orc voice the skills use in success lines.
- `.claude/skills/` when using Claude Code and you want `/ship`, `/land`,
  `/roast`, `/yap`, `/lore`, `/runes`, `/warchief`, and `/watchtower`.
- `hooks/hooks.json` and `hooks/watchtower-nudge.sh` for the ambient
  `watchtower` nudge. This directory is only auto-discovered when loaded as
  a Claude Code plugin; outside that, copy both files to `hooks/` at your
  project root and copy the `hooks` object from `hooks/hooks.json` into your
  own `.claude/settings.json`. The command falls back from
  `${CLAUDE_PLUGIN_ROOT}` to `${CLAUDE_PROJECT_DIR}`, so it resolves either
  way without editing the path.

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
