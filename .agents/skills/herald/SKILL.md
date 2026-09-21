---
name: herald
description: Have the AI draft release notes for a tag or the unreleased work since the last one, grounded in the pull requests actually merged, then write them into the GitHub release once the user approves. Use when the user says herald, asks for release notes, or wants a release described.
---

# Herald Workflow

Use this skill when the user asks the AI to write release notes: what a
release, or the work waiting for one, actually changed, told for the people
who use the project rather than the people who built it.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Requirements](#requirements)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Notes Format](#notes-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Resolve the range: a named tag against the tag before it, or the last tag
   to the base branch's head for unreleased work.
2. Collect the pull requests merged in that range, with their titles,
   bodies, and linked issues.
3. Draft notes grouped by what changed for users, each item citing its pull
   request.
4. Show the draft in chat. Stop there unless the user asks to publish it.
5. On the user's current-turn go-ahead, write the notes into the GitHub
   release for that tag.

## What This Is Not

- Not a changelog generator. Tools such as release-please, changesets, and
  semantic-release own `CHANGELOG.md` where a repository uses them, and a
  hand edit there is overwritten or conflicts with the next release. This
  skill never edits `CHANGELOG.md` or any other file.
- Not `chronicle`: `chronicle` writes Markdown docs into the repository.
  Release notes live on the hosting platform's release, not in a file.
- Not a release tool. It never creates a tag, bumps a version, merges a
  release pull request, or publishes a draft release.
- Not permission to describe changes the merged pull requests don't show.

## Trigger Rules

- Run when the user explicitly asks for release notes, asks to describe a
  release or what shipped since the last one, or says herald.
- Drafting is read-only and needs no approval. Writing the notes to a
  release is a mutation under `context/policies/approval-policy.md` (the
  target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/policies/approval-policy.md`): a request for
  notes is a request for the draft, not for the write. Publish only when the
  current turn asks for it.

## Requirements

- A GitHub MCP connector configured for this session, or `gh` installed and
  authenticated, to read releases, tags, and pull requests.
- `gh` with write access to publish. The GitHub MCP connector exposes
  release reads (`list_releases`, `get_release_by_tag`,
  `get_latest_release`) but no release write, so the write goes through
  `gh release`.

## Prerequisites

- Read `context/policies/docs-policy.md` and
  `context/policies/writing-guidelines.md`, using the target repo's copy of
  each when it exists; otherwise use the bundled copy at
  `${CLAUDE_PLUGIN_ROOT}/context/policies/<file>`. The notes follow their
  grounding and tone rules.
- Read the target repo's config file — `.orchraft.jsonc`, else
  `.orchraft.json` — when one exists, per `context/policies/config-policy.md`,
  for `baseBranch`. Without it, the base branch is the repository's default
  branch; do not assume `main`.
- Fetch tags fresh (`git fetch --tags`) before resolving a range, so a tag
  created since the last fetch isn't missed.

## Default Path

1. Resolve the range:
   - **A named tag** — from the previous tag to that tag. The previous tag is
     the nearest earlier one by version order among tags following the same
     pattern (`v1.2.0` before `v1.3.0`), not whichever was created last.
   - **Unreleased work** (the default when no tag is named) — from the
     latest tag to the head of the base branch.
   - **No earlier tag** — from the repository's first commit, and say so in
     the handoff.
2. List the commits in the range (`git log --first-parent <from>..<to>` on
   the base branch) and map each to its pull request: the `(#123)` suffix a
   squash merge leaves, the `Merge pull request #123` subject a merge commit
   leaves, or the platform's commit-to-pull-request lookup for a rebase
   merge, which leaves neither. A commit pushed straight to the base branch
   has no pull request but is still part of the release; use its own message,
   and cite its short SHA where a pull request number would go.
3. Read each pull request's title and body, and the issues it closes. These
   say what changed and why; the commit titles alone often don't.
4. Drop what users never see: release pull requests themselves (such as
   release-please's `chore: release`), dependency bumps with no behavior
   change, and CI or tooling changes. Keep a dependency bump that fixes a
   vulnerability or changes supported versions.
5. Draft the notes per [Notes Format](#notes-format) and show them in chat.
6. When the user asks to publish, wrap the notes between the hidden markers
   `<!-- herald:start -->` and `<!-- herald:end -->` so a later run can find
   them, then check the release for that tag:
   - **It exists** — when the body already holds that block from an earlier
     run, replace only what lies between the markers; otherwise put the block
     above the current body, separated by a horizontal rule. Replace the
     whole body only when the user asks for that. GitHub keeps no history of
     release bodies, so a replacement would lose whatever a release tool
     wrote there. Write with
     `gh release edit "$tag" --notes-file "$file"`.
   - **The tag exists but has no release** — create a draft with
     `gh release create "$tag" --draft --verify-tag --notes-file "$file"`
     and leave publishing it to the user. `--verify-tag` makes `gh` abort
     rather than create a missing tag.
   - **Unreleased work** — there is nothing to write to yet. Say so, and
     offer to publish once the release exists.
7. Read the release back and confirm its body holds exactly one marked
   block containing the notes before reporting success.

## Notes Format

- Group by what changed for users, in this order, and omit empty groups:
  **Breaking changes**, **Features**, **Fixes**, **Documentation**, **Other**.
  A commit type is a hint, not the answer: a `fix:` that changes a default
  may be a breaking change.
- One bullet per change, in plain language, stating what a user can now do
  or what stopped going wrong. End each with its pull request number, such
  as `(#42)`, or the short SHA of a direct commit that has none, such as
  `(a1b2c3d)`. Several pull requests that deliver one change share a bullet.
- Every breaking change says what to do about it.
- No marketing language, no emoji, and no orc voice. Release notes are
  release text, which `context/personality.md` keeps plain.
- If the repository has earlier release notes written by hand, match their
  shape instead.

## Guardrails

- Never edit, stage, or commit files, including `CHANGELOG.md`.
- Never create a tag, bump a version, or publish a draft release.
- Never write to a release without the user's current-turn go-ahead, and
  never replace an existing release body unless the user asks for a
  replacement specifically.
- Never describe a change no merged pull request or commit in the range
  shows. When a pull request's body doesn't say what changed for users,
  describe it from its diff, or mark the gap in the draft rather than
  guessing.

## Stop Conditions

- Stop if the named tag doesn't exist.
- Stop if the range holds no commits; say the tag or base branch has nothing
  new to announce.
- Stop before publishing if `gh` is unavailable or lacks write access, and
  leave the draft in chat.
- Stop if the release body changed between reading it and writing it. Read
  it again, rebuild the combined body, and confirm with the user before
  writing.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Herald from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain result instead. The line is the skill's own message, never part
  of the notes.
- Report the range and how many pull requests it covered.
- Show the drafted notes.
- After publishing, report the release URL and which write happened: the
  notes added above the existing body, the block from an earlier run
  updated, the whole body replaced, or a draft release created.
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Notes drafted:

```text
📯 Hrrm. Seven raids since v0.1.0, ready to be cried from the walls.

Range: `v0.1.0`..`main`, 7 pull requests.

## Features
- Add an optional `.orchraft.jsonc` for fixed choices such as merge
  method. (#42)
...

Say publish once the release exists to write these into it.
```

Notes published:

```text
📯 The horn is sounded. v0.2.0 carries its news.

https://github.com/example/repo/releases/tag/v0.2.0
Placed above release-please's generated list.
```

Blocked:

```text
⚠️ Tag `v0.3.0` doesn't exist. Nothing was drafted.
```
