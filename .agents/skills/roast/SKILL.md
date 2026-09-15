---
name: roast
description: Have the AI review the current pull request's diff against the target repository's own policies and commit history — not an external ruleset — then post the findings as a PR review with inline comments and a summary. Use when the user says roast, review, asks for a PR review, or wants CodeRabbit-style automated review after shipping.
---

# Roast Workflow

Use this skill when the user asks the AI to roast (review) a pull request, or
right after `ship` opens/updates one and the user asks for a review pass on
it.

## Contents

- [At A Glance](#at-a-glance)
- [Requirements](#requirements)
- [What This Is Not](#what-this-is-not)
- [Trigger Rules](#trigger-rules)
- [Sources Of Truth](#sources-of-truth)
- [Prerequisites](#prerequisites)
- [Default Path](#default-path)
- [Severity Guide](#severity-guide)
- [Comment Format](#comment-format)
- [Guardrails](#guardrails)
- [Stop Conditions](#stop-conditions)
- [Handoff](#handoff)

## At A Glance

1. Confirm there is an open pull request for the current branch.
2. Read the actual PR diff, not just the working tree.
3. Check the diff against this repo's own policies, not external style rules.
4. Report findings by severity, then post them as a single PR review: one
   comment anchored to each finding's diff line, plus one summary.
5. Stop. Do not push fixes unless the user explicitly asks.

## Requirements

What the end user needs in place before this skill can work at all:

- A GitHub MCP connector configured for this session, authenticated as an
  account with comment/review write access to the repository (not just read).
  Without write access, findings can still be produced but never posted.
- `gh` installed and authenticated as a fallback path, for when the MCP
  connector is unavailable mid-session.
- The branch must already have an open, non-draft pull request — run `ship`
  first if it doesn't. This skill reviews an existing PR; it does not create
  one.
- `context/policies/` present in the repo for the policy-compliance checks to
  mean anything; if this repo doesn't have them, that check is skipped rather
  than invented (see [Sources Of Truth](#sources-of-truth)).

## What This Is Not

- Not a fix workflow. It reports; it does not edit code.
- Not a replacement for `ship`'s commit-time validation — this runs against
  the PR as a whole, after it exists.
- Not permission to approve, merge, or request changes on the PR unless the
  user explicitly asks; posting a comment is not a review decision.
- Not a search for an external "coderabbit ruleset." This repo's own
  `context/policies/` files and code are the standard, not a hosted or
  invented rulebook.

## Trigger Rules

- Run when the user explicitly asks to roast, review, review the PR, or check
  the branch the way an automated reviewer would.
- Run immediately after `ship` when the user asks `ship` to include a review,
  or says so as a standing preference (e.g. "always roast after you ship").
- Do not run automatically on every `ship` unless the user has said so; `ship`
  and `roast` are separate skills with separate trigger rules.

## Sources Of Truth

Rely on what already exists in this repo instead of an external knowledge
base:

- `context/policies/branch-policy.md`, `context/policies/commit-policy.md`,
  and `context/policies/writing-guidelines.md` for naming, commit, and PR-text
  compliance.
- `context/policies/review-policy.md` for reviewer priority order, severity
  levels, and findings format — do not invent a different taxonomy.
- The PR's own commit history for whether Conventional Commits was actually
  followed, not just the final diff.
- Any project-local architecture, design-system, or lint/CI config already in
  the repo (e.g. `CLAUDE.md`, `AGENTS.md`, linter configs, CI workflow files).
  Read what the repo already enforces; do not assume rules it does not have.
- The PR description and linked issue/task, if any, as the benchmark for scope
  — read it before judging whether something is missing or out of scope.

If the repo has none of the above beyond generic conventions, review against
correctness, the conventions already visible in the surrounding code, and the
policies above only.

## Prerequisites

- Call `get_me` first to confirm the connected GitHub identity and its access
  before doing anything else — this predicts permission failures (fork PRs,
  read-only tokens) instead of discovering them after building the review. If
  the MCP path is unavailable, use `gh api user` as the equivalent identity
  check before continuing.
- Confirm the current branch is non-`main` and has an open, non-draft pull
  request; use the GitHub MCP connector to fetch it, falling back to `gh`
  only if the MCP path is unavailable or blocked. If no PR exists yet, that
  most likely means `ship` hasn't run on this branch — say so instead of a
  generic "no PR found."
- Fetch the full PR diff and commit list from GitHub, not a local `git diff`
  guess — the PR may include commits from other pushes.
- Record the PR's current head SHA, base SHA (or an equivalent diff-identity
  hash), and state (open) before reviewing, and re-check all of them
  immediately before posting — if the head or base changed (a force-push, a
  new commit, or a retargeted base branch), re-fetch the diff and recompute
  findings instead of posting against a stale one; if the PR was merged or
  closed while the review was being built, stop and report that instead of
  posting to a PR that's no longer open.
- Check for an existing pending review on the PR (`pull_request_review_write`
  method `get`/list, or the equivalent read). Never auto-discard it, even if
  it belongs to the connected account — account ownership doesn't tell you
  whether it's a stale leftover from an interrupted run or a still-active
  review from the same account running concurrently in another session. If
  one exists, stop and surface it to the user for confirmation before
  proceeding, without requesting Copilot or making any other PR mutation
  (see Stop Conditions).
- If the PR author matches the connected account from `get_me` (a
  self-review), a self-authored review isn't independent input. Requesting
  GitHub Copilot as a reviewer via `request_copilot_review` is itself a PR
  mutation, so it falls under AGENTS.md's rule requiring the user's explicit
  go-ahead in the current turn — running `roast` does not itself authorize
  it. Ask the user once whether to request Copilot as an independent second
  opinion before doing so; proceed with just your own findings if they
  decline or don't respond in this turn. Skip asking entirely if the tool
  isn't available in this session, the repo doesn't support it, or Copilot
  has already been requested/reviewed on this PR.
- Check for this skill's prior review(s) on the PR: find the latest review
  body ending in the `<!-- roast:review head=<sha> -->` marker (see Comment
  Format), and use that SHA as the prior review's commit. If one exists, review
  only the code delta since that commit and note which earlier
  findings still stand, were fixed, or no longer apply — do not re-post
  unchanged findings as if they were new. Scope and policy compliance (PR
  title, description, branch name) are PR-level, not commit-level — re-check
  those against their current state every time, even on a delta review.
- Read the sources listed above before judging anything.

## Default Path

1. Fetch the PR (title, body, commits, diff) through the GitHub MCP connector.
2. Compare the diff against the PR description/linked task — flag scope gaps
   in either direction (planned-but-missing, or shipped-but-unplanned).
3. Check policy compliance: branch name, each commit title/body, and the PR
   title/body against `context/policies/`.
4. Scan the full diff for hardcoded secrets, tokens, keys, or credentials
   first, before any file-type exclusion, and flag any as Critical — this
   check applies to every file in the diff, generated/vendored/lockfiles
   included, since leaked credentials show up in those as often as in
   hand-written code.
5. Check the code itself: correctness, error handling, edge cases, and
   consistency with existing patterns in the touched files. Skip generated,
   vendored, or lockfile diffs (e.g. `*.lock`, `dist/`, `node_modules/`,
   checked-in build output) for this correctness pass only — no human
   authored those lines. If the diff is too large to read in one pass,
   review file-by-file, prioritizing logic and security-sensitive files over
   docs/config, rather than silently truncating or skipping the rest.
6. Rank findings by severity (see below). Group findings that land on the
   same file/line into a single inline comment instead of stacking multiple
   comments on one line.
7. Post the findings as one PR review through the GitHub MCP connector:
   - `pull_request_review_write` with method `create` to open a pending
     review.
   - `add_comment_to_pending_review` once per remaining file/line, capped at
     20 inline comments. Beyond the cap, add the rest to the summary body's
     Unanchored findings block instead of continuing to post individual
     comments — a wall
     of inline comments is noise, not signal. If any `add_comment_to_pending_review`
     call fails, stop adding further comments and do not call
     `submit_pending` — report the failure and that a pending review was
     left partially built on the PR (see Stop Conditions).
   - `pull_request_review_write` with method `submit_pending` (event
     `COMMENT`, never `REQUEST_CHANGES`/`APPROVE` unless the user asks) using
     the summary report as the review body.
   A finding can only anchor to a line inside the diff's hunks — GitHub
   rejects comments on unchanged lines. Route any finding without a valid
   diff-line anchor (e.g. "this untouched file should have been updated too")
   into the summary body's "Unanchored findings" section instead of dropping
   it or erroring.
   Fall back to `gh api repos/<owner>/<repo>/issues/<number>/comments -f
   body=<report>` to post the full report as one issue comment only if the
   MCP review-write path is itself unavailable — it returns a parseable
   `id`/`html_url`, unlike relying on console output from `gh pr comment`.
8. Confirm `submit_pending` (or the `gh` fallback) actually returned a review
   ID/URL before declaring success — a call that doesn't error is not proof
   it posted. For the `gh` fallback, validate the response's `id`/`html_url`,
   or read back the PR's issue comments and match the one just created;
   don't assume success from the absence of an error.
9. Report the same findings to the user in the chat response.

## Severity Guide

See `context/policies/review-policy.md` for the severity levels
(Critical/Important/Minor) and reviewer priority order findings must follow.

## Comment Format

Inline comment (one per line-specific finding, via
`add_comment_to_pending_review`): carry the fields from
`context/policies/review-policy.md`'s Findings Format section (severity,
finding, why it matters / what to do) and render them in the same visual
language as the review body, top to bottom:

1. **Severity alert**: a GitHub alert whose color matches the severity, with
   the same emoji as the scoreboard. Use `[!CAUTION]` 🚨 for Critical,
   `[!WARNING]` ⚠️ for Important, `[!NOTE]` 💡 for Minor, and `[!TIP]` 🤔
   for a judgment call. Its first line is the bold severity plus a
   two-to-four-word topic.
2. **What's wrong**: one or two sentences, with code identifiers, paths, and
   headings in backticks.
3. **🛠️ Fix**: the concrete remediation, starting with a verb.
4. **Suggestion block** (optional): when the fix is a small change to the
   anchored lines, add a ` ```suggestion ` block so the author can apply it
   in one click. Anchor the comment's `startLine`..`line` (side `RIGHT`) to
   exactly the lines the block replaces; omit it when the fix spans other
   lines or files.
5. **🤖 Prompt for AI agents**: a collapsed `<details>` holding a
   ` ```text ` block the author can paste into any coding agent. Make it
   self-contained, since the agent won't see the PR: file path and line
   range, what's wrong, the fix, and how to confirm it worked. Keep it to
   plain instructions with no emoji or alert markup.

````markdown
> [!NOTE]
> **💡 Minor** · Table of contents out of sync

`Contents` stops at `Handoff`, but the file has a `## Response Examples`
section (line 114). `land`'s Contents already lists it.

**🛠️ Fix:** Add the missing entry so the table of contents matches the file.

```suggestion
- [Handoff](#handoff)
- [Response Examples](#response-examples)
```

<details>
<summary>🤖 Prompt for AI agents</summary>

```text
In .agents/skills/yap/SKILL.md, the Contents list (lines 12-21) ends at
"- [Handoff](#handoff)" but the file also has a "## Response Examples"
section. Add "- [Response Examples](#response-examples)" after the Handoff
entry. Confirm every "## " heading in the file has a matching Contents entry.
```

</details>
````

When several findings share one line (see Default Path step 6), post one
comment with an alert per finding, most severe first, and at most one
suggestion block. Keep one prompt per finding.

Review-body summary (the `submit_pending` body, covers everything that isn't
line-specific plus a rollup). Layout, top to bottom:

1. **Verdict callout** (always visible) — a GitHub alert, which renders as a
   colored box: `[!TIP]` (green) for zero issues, `[!WARNING]` (amber) for
   important/minor issues only, `[!CAUTION]` (red) when anything is critical.
2. **Scoreboard table** (always visible) — counts per severity plus judgment
   calls.
3. **One collapsed `<details>` per section** — bold name, topical emoji, and
   status in the `<summary>`. Put the section's checks in a ` ```diff ` block:
   `+` lines render green (passing check), `-` lines render red (issue),
   lines starting with a space stay neutral (judgment calls — not enforced).
   Hard-wrap at ~76 characters and repeat the same prefix on continuation
   lines; GitHub won't soft-wrap code blocks and an unprefixed continuation
   loses its color.
4. **`---` then a collapsed "Review info" footer** — commit range, full vs.
   delta review, files reviewed, standards used.
5. **Hidden marker** `<!-- roast:review head=<sha> -->` as the last line, so a
   later pass can find this skill's prior review and its commit reliably.

Keep GitHub alerts and the table at the top level — alerts don't render
inside `<details>`. Every `<details>` must open and close in a matched pair;
count them before posting, since one stray tag breaks the nesting of
everything after it.

````markdown
## 🔥 Roast — <PR title>

> [!TIP]
> **Clean pass.** Nothing blocking. <[M] judgment call(s) worth a glance.>

| 🚨 Critical | ⚠️ Important | 💡 Minor | 🤔 Judgment calls |
| :---: | :---: | :---: | :---: |
| **[n]** | **[n]** | **[n]** | **[n]** |

<details>
<summary><b>🔭 Scope</b> — [✅ Pass / ❌ Issues / 🤔 Judgment call]</summary>
<br>

```diff
+ ✅ planned vs. shipped, no gaps
```

</details>

<details>
<summary><b>📐 Policy compliance</b> — [status]</summary>
<br>

```diff
+ ✅ branch name matches branch-policy.md
+ ✅ commit title/body follow commit-policy.md
- ❌ [IMPORTANT] PR body missing Validation section — add what ran
```

</details>

<details>
<summary><b>🔍 Code review</b> — [status]</summary>
<br>

```diff
+ ✅ no secrets in diff
  🤔 [JUDGMENT CALL] <note> — see inline comment
```

</details>

<details>
<summary><b>📎 Unanchored findings</b> — [count]</summary>
<br>

```diff
- ❌ [SEVERITY] <finding> — <required remediation>
```

<details>
<summary>🤖 Prompts for AI agents</summary>

```text
1. <self-contained prompt for the first unanchored finding>
2. <self-contained prompt for the next one>
```

</details>

</details>

---

<details>
<summary>ℹ️ Review info</summary>
<br>

- **Commits:** `<base-sha>`..`<head-sha>` (<full review / delta since `<sha>`>)
- **Files reviewed (<n>):** `<path>`, `<path>`
- **Standards:** `context/policies/review-policy.md`, `context/policies/`

</details>

<!-- roast:review head=<head-sha> -->
````

Omit the `Unanchored findings` block entirely when there are none — don't
post an empty collapsed section.

Write the finding text in the tone required by
`context/policies/writing-guidelines.md`: concise, technical, no marketing
language. The emoji, alerts, and color conventions above are this section's
own formatting, not a `writing-guidelines.md` requirement, and don't extend to
PR titles or descriptions.

## Guardrails

- Never edit files, commit, or push as part of this skill.
- Never approve, merge, or request-changes the PR unless the user explicitly
  asks for that decision.
- Post one review per pass (one pending review, submitted once); do not open
  multiple pending reviews or submit partial reviews one comment at a time.
- Do not invent policies this repo does not have. If something looks wrong
  but no policy or visible convention covers it, tag it `[JUDGMENT CALL]`
  per `context/policies/review-policy.md`, not a severity.

## Stop Conditions

- Stop if there is no open, non-draft pull request for the current branch —
  say to run `ship` first rather than just "no PR found."
- Stop if the GitHub MCP connector and `gh` are both unavailable — report the
  findings in chat only and say the PR comment could not be posted.
- Stop if the connected account lacks permission to comment (e.g. a
  fork-originated PR) — report this as a permissions issue, not as MCP being
  down, and share the findings in chat instead.
- Stop before posting if the user asked for a private/local review only.
- Stop and re-fetch instead of posting if the PR head SHA changed since the
  diff was fetched; do not post a review against a diff that no longer
  matches the PR.
- Stop if the PR was merged or closed after the review was fetched but before
  it was posted — report the findings in chat and do not post to a PR that's
  no longer open.
- Stop if a pending review already exists on the PR — report it and ask the
  user to confirm discarding it (or resolve it on GitHub themselves) before
  proceeding; never discard it automatically.
- If `add_comment_to_pending_review` or `submit_pending` fails after inline
  comments were already added, do not exit silently — report that a pending
  review was left partially built on the PR, with the findings in chat, so
  the user knows it needs manual
  submission or discarding on GitHub.

## Handoff

- Only use the success phrasing below once the post is confirmed (a returned
  review ID/URL), not just because the API call didn't error.
- Use a warm, lively one-line roast phrase when the workflow succeeds, such
  as `🔥 Roast's in. Nothing left unroasted. ✨`
- Report the PR number and the finding counts by severity.
- If there were zero findings, say so plainly and skip listing severities.
- If posting stops or fails, skip the lively phrasing and state the blocker
  plainly, then share the findings in chat instead.

## Response Examples

Clean review, no findings:

```text
✅ Clean pass. Nothing to flag on this one.

PR #123: 0 issues found.
```

Review with findings:

```text
🔥 Roast's in. Nothing left unroasted. ✨

PR #124: 3 issues found — 1 critical, 1 important, 1 minor.
Posted as a PR review with inline comments plus a summary.
```

Blocked review:

```text
⚠️ Roast is blocked: no open pull request on this branch yet.

Run `ship` first, then roast. No comment or review was posted.
```
