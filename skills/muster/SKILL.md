---
name: muster
description: Have the AI report actionable open-PR state across every repo the connected GitHub account owns — failing/pending checks, merge conflicts, unresolved roast findings — grounded in live data, not one repo at a time. Use when the user says muster, asks for a portfolio status, wants to know what's actionable across all their repos, or asks "what needs my attention today".
---

# Muster Workflow

Use this skill when the user wants a status pass across their whole GitHub
account, not just the current repo — every other status skill here
(`runes`, `watchtower`, `reckoning`, `plunder`) is scoped to one repo.

## Contents

- [At A Glance](#at-a-glance)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Requirements](#requirements)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Summary Format](#summary-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)
- [Response Examples](#response-examples)

## At A Glance

1. Enumerate every repo the connected account personally owns (not org
   membership), excluding forks and archived repos.
2. For each repo's open pull requests, check failing/pending checks, merge
   conflicts, and unresolved review-thread counts — the same live checks
   `hooks/watchtower-nudge.sh` already runs for one branch's PR, fanned out
   across every open PR in every repo.
3. Report only what's actionable, the same "quiet unless there's something
   to say" instinct `watchtower` uses — not a wall of "repo X: all clear"
   lines.
4. Stop. Never touch a PR/issue — this skill only reads.

## What This Is Not

- Not `watchtower`: `watchtower` is a one-line ambient nudge for the current
  repo's current branch; Muster is an invoked, multi-repo report covering
  every open PR across the whole account.
- Not `reckoning`/`plunder`: both are single-repo historical reports (every
  PR ever, open/closed/merged). Muster looks at live, open-PR state only,
  across many repos — it does not walk closed or merged history anywhere.
- Not permission to act on anything it finds — a failing check or an
  unresolved finding is information for the chief to route to `ship`,
  `roast`, or `land` on a specific repo, not something this skill acts on
  itself.

## Trigger Rules

- Run when the user explicitly asks for a muster, a portfolio status, what's
  actionable across their repos, or "what needs attention today" across more
  than the current repo.
- Do not run automatically; every other status-reporting skill here
  (`runes`, `reckoning`, `plunder`, `watchtower`) is invoke-on-purpose, and
  this one is no different — this is explicitly not a second ambient hook.

## Requirements

- `gh` installed and authenticated. Repo enumeration needs `gh api
  --paginate user/repos`, since no MCP tool in this session exposes "every
  repo I own" as a direct list — `search_repositories` is a search index
  (query `user:<login>`), not the authoritative access list, and can lag or
  miss private repos depending on token scope. Per-PR checks still prefer
  the GitHub MCP connector when available, falling back to `gh` the same as
  every other skill.
- Without `gh` authenticated, stop and say the muster can't run rather than
  reporting a partial or single-repo result as the whole portfolio.

## Prerequisites

- Confirm the connected identity via `get_me` when MCP is available. Repo
  enumeration always goes through `gh` regardless (no MCP tool exposes it
  directly — see below), so also run `gh api user --jq .login` and compare
  it against `get_me`'s login before enumerating. If they differ, the
  account whose repos get enumerated isn't the one the report would label
  as "Account" — stop and surface the mismatch rather than silently
  reporting one identity's login against another identity's repos. When
  MCP is unavailable, `gh api user --jq .login` is the only identity check
  and needs no cross-check against itself.
- Enumerate every repo: `gh api --paginate --method GET user/repos -f
  affiliation=owner --jq '.[] | select(.fork==false and .archived==false) |
  {name, owner: .owner.login, full_name}'`. The explicit `--method GET`
  matters here, not just style: `gh api` switches its default method from
  GET to POST the moment any `-f`/`-F` field is present, and `POST
  /user/repos` creates a new repository rather than listing them — the
  opposite of this skill's read-only guarantee. Page through every page the
  same way `reckoning`'s own `gh api --paginate` fallback does — a single
  page under-covers an account whose repo count exceeds one page. This
  lookup is unverified in this repo until exercised live against a real
  account; confirm the shape of a real response before trusting it at
  scale, the same caution `plunder`'s new thread-attribution lookup got.
- For each enumerated repo, list its open pull requests (`list_pull_requests`
  with `state: open`, or `gh api --paginate
  "repos/$owner/$repo/pulls?state=open"` when MCP is unavailable), including
  each PR's `draft` field — it comes back in the same listing call, no
  separate fetch needed. A repo with zero open PRs needs no further
  check — move on without reporting it.
- For each open PR, gather the same live facts
  `hooks/watchtower-nudge.sh` already checks for one PR:
  - Check/status rollup via `pull_request_read` method `get_check_runs` —
    any failing, errored, cancelled, or timed-out run; any still pending,
    in-progress, or queued run. `get_status` (the older combined-status
    API) doesn't distinguish cancelled/timed-out from a plain failure and
    can't see individual check-run states, so it isn't a real substitute:
    when `get_check_runs` itself isn't available, report the PR's checks
    as unverified rather than falling back to `get_status` as if it gave
    equivalent information.
  - Mergeable state (`mergeable_state` / `mergeStateStatus`) — `dirty`
    flags a real conflict; `unknown` means GitHub hasn't finished
    computing mergeability yet and is reported as unverified, not assumed
    clean; `draft` (some mergeable_state responses report this directly,
    in addition to the PR's own `draft` field already captured above)
    excludes the PR from "no detected issues" the same way the `draft`
    field does; `unstable` stays on the checks/status path above rather
    than being treated as its own merge-conflict category.
  - Unresolved review-thread count via `pull_request_read` method
    `get_review_comments` (or the same paginated GraphQL
    `reviewThreads(first: 100, after: $cursor)` loop the hook script and
    `reckoning` both already use), counting threads where
    `is_resolved`/`isResolved` is false. Only report a PR's unresolved count
    as confirmed when this check actually completed — a failed or
    incomplete thread query means "unverified," never "assume zero."
- A repo or PR whose check fails partway through (a listing page errors, a
  thread query can't complete) is reported as unverified for that one
  repo/PR, not silently dropped or assumed clean — the muster continues to
  the next repo rather than aborting the whole pass for one failure.

## Default Path

1. Confirm identity (see Prerequisites).
2. Enumerate every owned, non-fork, non-archived repo.
3. For each repo, list open PRs; skip repos with none.
4. For each open PR, gather checks/status, mergeable state, and unresolved
   review-thread count per Prerequisites.
5. Classify each PR: failing checks, pending checks, merge conflict,
   unresolved `roast`-style findings, no detected issues, or unverified
   (a check that couldn't complete). "No detected issues" reports only what
   this skill actually checked — it is not a land-readiness guarantee.
   Unlike `land`'s own preconditions, this pass never checks draft state or
   required-review approval status; a draft PR or one still missing a
   required approval can otherwise show no detected issues under the
   checks this skill runs. Report a draft PR's draft state explicitly
   alongside its classification instead of letting it read as ready.
6. Report only repos/PRs with something actionable or unverified, per
   [Summary Format](#summary-format) — omit clean repos from the listed
   detail, but still count them in the totals.

## Summary Format

Keep it to what's actionable — a clean repo gets counted, not narrated.

- **Account** — the connected login, and how many repos were counted
  (owned, non-fork, non-archived) vs. how many had at least one open PR.
- **Actionable** — one line per PR that needs attention: repo, PR
  number/URL, and why (failing check, pending check, merge conflict,
  N unresolved findings) — grouped by repo.
- **Unverified** — any repo or PR whose check couldn't complete, reported
  separately from a confirmed-clean result.
- **Clean** — a count only ("N repos, M open PRs, all clean") — no per-PR
  detail for PRs with nothing actionable.

## Guardrails

- Never touch a PR or issue, resolve a thread, or post a reply as part of
  this skill — it only reads.
- Never walk closed or merged PR history — that's `reckoning`/`plunder`'s
  job, not this skill's; Muster stays scoped to open PRs only.
- Never report a repo's or PR's check as "clean" when the underlying query
  didn't actually complete — report it as unverified instead of assuming
  the best case.
- Never expand scope to org-owned repos the account doesn't personally own
  — `affiliation=owner` only, matching this skill's own stated scope.

## Stop Conditions

- Stop and say so if `gh` isn't installed or authenticated — repo
  enumeration has no MCP path in this session, so there's no fallback left
  to try.
- Stop and say so if repo enumeration itself fails or can't be paginated to
  completion — don't report a partial repo list as the whole portfolio.
- A failure scoped to one repo or PR's checks (not enumeration itself)
  doesn't stop the whole pass — report that one item as unverified and
  continue, per Prerequisites.
- Stop after presenting the summary; do not proceed into `ship`, `roast`,
  `land`, or any mutation on any repo without the user separately asking
  for it, naming that repo.

## Handoff

- Unless the user asked for plain output, open with a fresh one-line phrase
  in the orc voice, speaking as the Warden from `context/personality.md`
  (the target repo's copy when it exists, otherwise
  `${CLAUDE_PLUGIN_ROOT}/context/personality.md`). If they did, open with
  the plain summary instead.
- Present the summary per [Summary Format](#summary-format).
- If blocked, drop the orc voice and state the blocker plainly.

## Response Examples

Opening lines are samples of the orc voice; write a fresh one each time.

Actionable state found (illustrative — actual output names real repos/PRs):

```text
🧭 Hrrm. Rode the whole realm: two strongholds need the chief's eye. ✨

Account: <login> (N repos counted, M with at least one open PR)
Actionable:
- <owner>/<repo-a> — PR #12: failing check `test`
- <owner>/<repo-b> — PR #7: 2 unresolved roast findings
Unverified: <owner>/<repo-c> — PR #3: review-thread check didn't complete
Clean: 6 repos, 9 open PRs, all clean
```

Whole portfolio clean:

```text
🧭 Hah! Every banner flies clean across the realm.

Account: <login> (N repos counted, M with at least one open PR, all clean)
```

Blocked, no gh access:

```text
⚠️ Muster is blocked: gh isn't installed or authenticated, and no MCP tool
in this session lists every repo the account owns. No pass was performed.
```
