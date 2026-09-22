---
name: muster
description: Have the AI report actionable open-PR state across every repo the connected GitHub account owns — failing/pending checks, merge conflicts, unresolved review threads — grounded in live data, not one repo at a time. Use when the user says muster, asks for a portfolio status, wants to know what's actionable across all their repos, or asks "what needs my attention today across my repos".
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
- This flow assumes `gh` is authenticated as a user-account token (a
  personal access token or OAuth token), since `gh api user` and
  `gh api user/repos` are user-to-server endpoints. A GitHub App
  installation token can't call either at all — it authenticates as the
  installation, not a user, and both calls would fail outright rather than
  silently narrow. That failure is caught by the existing "stop if `gh`
  isn't authenticated" path; this skill doesn't implement a separate
  installation-token path (`GET /installation/repositories` under
  app-installation auth), so an installation token is out of scope here,
  not a case that produces a misleadingly narrow result.
- A *fine-grained* personal access token, by contrast, does work with
  `/user` and `/user/repos`, but can be scoped to a chosen subset of repos
  rather than every repo the account owns — the response returns only what
  the token can see, with no field flagging that it's partial. This skill
  has no way to independently confirm a PAT's real scope, so it can't
  detect this case; note it as a caveat in the report (see Summary Format)
  rather than silently presenting a scoped token's count as the whole
  portfolio.

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
  "repos/$owner/$repo/pulls?state=open"` when MCP is unavailable), paginating
  through every page of MCP results too, not only the `gh` fallback — a repo
  with more open PRs than one page holds still needs every one counted.
  Include each PR's `draft` field — it comes back in the same listing call,
  no separate fetch needed. A repo with zero open PRs needs no further
  check — move on without reporting it.
- For each open PR, gather the same live facts
  `hooks/watchtower-nudge.sh` already checks for one PR:
  - Check/status rollup via `pull_request_read` method `get_check_runs`,
    paginating through every page. A run's `conclusion` (only set once
    `status` is `completed`) of `failure`, `cancelled`, or `timed_out` is a
    failing check; `action_required` and `stale` are actionable the same
    way — GitHub uses both for a run that needs attention before the PR can
    proceed, not a passive wait state. A `status` of `queued`,
    `in_progress`, `requested`, `waiting`, or `pending` is still pending. A
    `status` of `completed` with `conclusion` `success`, `neutral`, or
    `skipped` is a passing run — contributes nothing to "actionable" or
    "unverified," unlike every other combination above. Only a
    `status`/`conclusion` combination none of these three groups
    (failing, pending, passing) names — including a value GitHub adds
    later — is reported as unverified,
    never silently folded into "no detected issues"; an unrecognized state
    is exactly the kind of gap this skill's own fail-closed rule exists to
    catch. `get_status` (the older combined-status API) doesn't distinguish
    any of the above from a plain failure and can't see individual
    check-run states, so it isn't a real substitute: when `get_check_runs`
    itself isn't available, or its own pagination fails partway through,
    report the PR's checks as unverified rather than falling back to
    `get_status` or a partial page as if either gave equivalent
    information.
  - `get_check_runs` only sees GitHub Checks API entries (GitHub Actions
    and Checks-API-integrated apps). A CI system that posts through the
    older Statuses API instead — a commit status, not a check run — never
    shows up there at all, so also call `pull_request_read` method
    `get_status` on the head commit as an *additional* source, not a
    replacement: a combined status of `failure`/`error` is a failing check,
    `pending` is a pending check, and an empty status list contributes
    nothing (neither actionable nor unverified) rather than being treated
    as a gap. This is additive to the `get_check_runs` classification
    above, which stays the primary, more granular source.
  - Mergeable state (`mergeable_state` / `mergeStateStatus`) — compare
    case-insensitively, since the REST field returns lowercase (`dirty`) and
    the GraphQL field returns uppercase (`DIRTY`), and this skill reads
    either depending on which tool answered. `dirty`/`DIRTY` flags a real
    conflict; `unknown`/`UNKNOWN` means GitHub hasn't finished computing
    mergeability yet and is reported as unverified, not assumed clean;
    `draft`/`DRAFT` (some mergeable-state responses report this directly, in
    addition to the PR's own `draft` field already captured above) excludes
    the PR from "no detected issues" the same way the `draft` field does;
    `unstable`/`UNSTABLE` stays on the checks/status path above rather than
    being treated as its own merge-conflict category; `blocked`/`BLOCKED`
    (branch protection requires a status check or review this PR hasn't
    met) is actionable on its own — GitHub's response doesn't say which
    requirement is unmet, so report it as blocked when a reason can be
    inferred from the checks/thread data already gathered, or unverified
    when it can't, but never let it fall through unclassified. `clean` is
    the one value that contributes nothing to either bucket. Any other
    value neither this list nor `clean` names — including one GitHub adds
    later — is reported as unverified, the same fail-closed catch-all the
    check-run classification above already uses.
  - Unresolved review-thread count via `pull_request_read` method
    `get_review_comments`, paginating through every page of threads (or the
    same paginated GraphQL `reviewThreads(first: 100, after: $cursor)` loop
    the hook script and `reckoning` both already use — nested per-thread
    comment pagination isn't needed, only `is_resolved`/`isResolved` on each
    thread's first page), counting threads where that field is false. This
    counts every unresolved thread on the PR, not only ones a `roast` review
    posted — the same convention `hooks/watchtower-nudge.sh` already uses
    (it has no per-thread provenance filter either). Report it as
    "unresolved review threads," not "roast findings," so an ordinary human
    review comment isn't mislabeled as one. Only report a PR's unresolved
    count as confirmed when this check actually completed — a failed or
    incomplete thread query means "unverified," never "assume zero." If the
    connected GitHub MCP server has a restricted or "lockdown" mode enabled
    that filters its own responses, this skill has no way to detect that
    from inside a query result — a filtered query can return successfully
    while still under-reporting threads. This is a caveat on the same
    "confirmed complete" claim, not a separate check to add; there's
    nothing this skill's own instructions can do to detect or work around a
    connector-level restriction it isn't told about.
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
   unresolved review threads, draft, no detected issues, or unverified (a
   check that couldn't complete). **Draft is its own classification, not a
   note folded into another one**: a draft PR reports as draft even when
   every other check comes back clean, and belongs in the Actionable list
   (see Summary Format) rather than silently landing in the clean-repo
   count, where a "report a draft PR's draft state" instruction with
   nowhere in the output to actually put it would otherwise go unfollowed.
   "No detected issues" reports only what this skill actually checked — it
   is not a land-readiness guarantee. This pass does check draft state (see
   Prerequisites); what it does *not* check, unlike `land`'s own
   preconditions, is required-review approval status — a PR still missing a
   required approval can otherwise show no detected issues under the checks
   this skill runs.
6. Report only repos/PRs with something actionable or unverified, per
   [Summary Format](#summary-format) — omit clean repos from the listed
   detail, but still count them in the totals.

## Summary Format

Keep it to what's actionable — a clean repo gets counted, not narrated.

- **Account** — the connected login, and how many repos were counted
  (owned, non-fork, non-archived) vs. how many had at least one open PR.
- **Actionable** — one line per PR that needs attention: repo, PR
  number/URL, and why (failing check, pending check, merge conflict,
  blocked by branch protection, N unresolved review threads, draft) —
  grouped by repo. A draft PR lists here even when every other check is
  clean.
- **Unverified** — any repo or PR whose check couldn't complete, reported
  separately from a confirmed-clean result.
- **Clean** — a count only ("N repos, M open PRs, all clean") — no per-PR
  detail for PRs with nothing actionable.
- **Coverage caveat** — a standing note that the repo count reflects what
  the authenticated token can see; a scoped fine-grained token or GitHub
  App installation token can silently narrow that below every repo the
  account actually owns, and this skill has no way to detect that case.

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
- <owner>/<repo-b> — PR #7: 2 unresolved review threads
- <owner>/<repo-d> — PR #4: draft
Unverified: <owner>/<repo-c> — PR #3: review-thread check didn't complete
Clean: 6 repos, 9 open PRs, all clean
Coverage: reflects what the authenticated token can see
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
