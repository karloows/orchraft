---
name: quest
description: Have the AI triage, create, or update a GitHub issue before implementation starts. Use when the user says quest, asks to file a bug, create an issue, triage a report, or update an issue's status, labels, or body.
---

# Quest Workflow

Use this skill when the user asks the AI to turn a report into a tracked
issue, or triage/update one that already exists — the lifecycle stage before
`ship`.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Requirements](#requirements)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Naming And Text](#naming-and-text)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Decide the intent: file a new issue, triage/search for duplicates, or
   update one that already exists.
2. Search existing issues before creating a new one.
3. Draft the title, body, labels, and type from the actual report, code, or
   git history, not a guess.
4. Create, update, or comment on the issue only with the user's current-turn
   go-ahead.
5. Report the issue number/URL and what changed.

## What This Is Not

- Not `ship`: never touches branches, commits, or pull requests.
- Not an implementation or design workflow — it tracks the work, it doesn't
  plan or build it.
- Not permission to close, reopen, or relabel an issue from an inferred
  connection to other work; only act on what the user explicitly confirms.
- Not a way to auto-file an issue for every complaint or aside in
  conversation — only when the user asks to track it.

## Trigger Rules

- Run when the user explicitly asks to quest, file or create an issue,
  triage a bug report, or update an issue's state, labels, or body.
- A bug report or complaint on its own is not a request to track it — ask
  before creating anything if the user hasn't said to file it.
- If the user asks to search or look up related issues without asking to
  create or update one, do that read-only and stop there.

## Requirements

- A GitHub MCP connector configured for this session, authenticated as an
  account with issue write access to the repository, for any create, update,
  or comment action. Without write access, a draft can still be produced but
  never posted.
- `gh` installed and authenticated as a fallback path, for when the MCP
  connector is unavailable mid-session.

## Prerequisites

- Call `get_me` (or `gh api user` as a fallback) to confirm the connected
  GitHub identity and its access before drafting anything meant to be posted.
- Search existing issues (`search_issues` for a conceptual/paraphrased query,
  `list_issues` for a direct filter) for likely duplicates before drafting a
  new one. If a strong match exists, surface it and ask whether to comment on
  the existing issue instead of opening a new one.
- Before setting `type` or any custom field on `issue_write`, check
  `list_issue_types` and `list_issue_fields` for the repository and only use
  values it actually supports; omit `type`/`issue_fields` entirely if the
  repository doesn't have them.
- Read any repository issue template (`.github/ISSUE_TEMPLATE/`) and follow
  its required fields first, falling back to a plain title/body when the repo
  has none.

## Default Path

1. Determine intent: create, update, or triage/search only.
2. To create: search for duplicates first (see Prerequisites). Draft a
   title, body, and labels grounded in the actual report, code, or git
   history. Use `issue_write` method `create`.
3. To update: fetch the current issue with `issue_read` method `get` first,
   so edits apply to its real current state instead of a stale assumption.
   Use `issue_write` method `update` for title/body/labels/state/type/field
   changes.
4. To comment: use `add_issue_comment`.
5. Confirm the write call actually returned an issue number, URL, or comment
   id before declaring success — a call that didn't error is not proof it
   posted.

## Naming And Text

- Issue title: concise and technical, following the tone rules in
  `context/policies/writing-guidelines.md` (no marketing language, no vague
  words like "stuff" or "things").
- Issue body: describe the actual problem or request with enough detail for
  someone else to act on it — reproduction steps for a bug, or the concrete
  outcome for a feature ask. Do not invent acceptance criteria, screenshots,
  or scope the user didn't give.
- Labels, type, and fields: only apply values that already exist in the
  repository's own label/type/field list; never invent one the repo doesn't
  have.

## Guardrails

- Never create, update, comment on, close, or reopen an issue without the
  user's current-turn go-ahead per `context/policies/approval-policy.md`.
- Never touch branches, commits, or pull requests as part of this skill —
  that's `ship`'s job.
- Never close or reopen an issue from an inferred connection to other work;
  only act on what the user explicitly confirms.
- Never invent a label, issue type, or custom field value the repository
  doesn't already define.

## Stop Conditions

- Stop if the user's message describes a problem but doesn't ask to track
  it — ask whether they want it filed instead of assuming.
- Stop if the GitHub MCP connector and `gh` are both unavailable — report the
  drafted issue content in chat instead.
- Stop if the connected account lacks issue write access — report this as a
  permissions issue, not as the connector being down, and share the draft in
  chat.
- Stop if a likely duplicate exists and the user hasn't said whether to file
  anyway or comment on the existing one instead.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line success
  phrase in the orc voice, speaking as the Herald from
  `context/personality.md` (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with the
  plain result instead.
- Report the issue number/URL and what changed (created, which fields were
  updated, or that a comment was posted).
- If a likely duplicate was found, report it even when the user chose to
  file anyway.
- If questing stops or fails, skip the phrase and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

New issue filed:

```text
📯 Hrrm. Quest posted: issue #45 marks the crash for the raiding party. ✨

Issue: https://github.com/example/repo/issues/45
Title: fix: null token crashes login on refresh
Labels: bug
```

Existing issue updated:

```text
📯 The board's been redrawn. Issue #40 now reads true.

Issue: https://github.com/example/repo/issues/40
Changed: labels (added `priority-high`), body (added repro steps).
```

Duplicate found, filed anyway:

```text
📯 Hrrm. A cousin quest already stands on the board.

Issue #38 looks like the same crash. Filed #46 anyway, per your call — worth
linking or closing one as a duplicate of the other later.
```

Blocked quest:

```text
⚠️ Quest is blocked: the connected account has no issue write access on this repo.

No issue was created. Draft:
Title: fix: null token crashes login on refresh
Body: <drafted body>
```
