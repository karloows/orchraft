#!/usr/bin/env bash
# SessionStart hook for the watchtower skill. Deterministic re-implementation
# of watchtower's own "What To Surface" rules (no nested `claude -p` call:
# these are plain state checks, not judgment calls). Emits at most one
# additionalContext line, or none if there's nothing actionable.
set -uo pipefail

emit() {
  jq -n --arg ctx "$1" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
  exit 0
}

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
if [ -n "$cwd" ] && ! cd "$cwd" 2>/dev/null; then
  # Don't fall through and report status for whatever directory we started
  # in -- an unreachable cwd means we can't trust which repo this is.
  exit 0
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Opt out via the repo's own config (context/policies/config-policy.md).
# Comments are stripped first: the format allows them, jq does not. A
# missing file, a missing key, or an unparseable one all leave the nudge on,
# so a broken config never silently disables the thing it configures.
#
# The strip tracks whether it is inside a double-quoted string, because a
# blind `s://.*::` also truncates at the // in a URL -- one "https://..."
# anywhere in the file would break the parse and silently strand the toggle.
strip_jsonc() {
  awk '{
    out = ""; inq = 0; i = 1; n = length($0)
    while (i <= n) {
      c = substr($0, i, 1)
      if (inq) {
        if (c == "\\") { out = out substr($0, i, 2); i += 2; continue }
        if (c == "\"") { inq = 0 }
        out = out c; i++
      } else {
        if (c == "\"") { inq = 1; out = out c; i++; continue }
        if (c == "/" && substr($0, i + 1, 1) == "/") { break }
        out = out c; i++
      }
    }
    print out
  }' "$1" 2>/dev/null
}

for cfg in .orchraft.jsonc .orchraft.json; do
  [ -f "$cfg" ] || continue
  # `== false` rather than `// empty` or a tostring compare: the alternative
  # operator treats a literal false as absent so it could never see
  # "disabled", and tostring would also accept the string "false", which is
  # the wrong type and per config-policy.md falls back to the default.
  disabled=$(strip_jsonc "$cfg" \
    | jq -r '(.hooks.watchtower.enabled == false) | tostring' 2>/dev/null)
  [ "$disabled" = "true" ] && exit 0
  break
done

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
status_output=$(git status --porcelain 2>/dev/null) || exit 0
dirty=""
[ -n "$status_output" ] && dirty=1

if [[ "$branch" =~ ^(main|master)$ ]]; then
  [ -n "$dirty" ] && emit "Chief, \`$branch\` has uncommitted changes."
  exit 0
fi

command -v gh >/dev/null 2>&1 || {
  [ -n "$dirty" ] && emit "Chief, \`$branch\` has local changes (gh not installed)."
  exit 0
}

# One gh call instead of a separate `gh auth status` probe first: capture
# stderr so a genuine "no PR for this branch" (gh exits 1 either way) can be
# told apart from an auth/network failure, instead of treating both the same
# or silently reading a failure as "there's no PR."
pr_stderr=$(mktemp 2>/dev/null)
pr_json=$(gh pr view "$branch" --json number,state,mergeStateStatus,statusCheckRollup 2>"$pr_stderr")
pr_rc=$?
pr_err=$(cat "$pr_stderr" 2>/dev/null)
rm -f "$pr_stderr" 2>/dev/null

if [ $pr_rc -ne 0 ]; then
  if printf '%s' "$pr_err" | grep -qi 'no pull requests found'; then
    [ -n "$dirty" ] && emit "Chief, \`$branch\` has local changes and no open PR yet."
  else
    [ -n "$dirty" ] && emit "Chief, \`$branch\` has local changes (GitHub status unavailable)."
  fi
  exit 0
fi

if [ "$(printf '%s' "$pr_json" | jq -r '.state // empty')" != "OPEN" ]; then
  [ -n "$dirty" ] && emit "Chief, \`$branch\` has local changes and no open PR yet."
  exit 0
fi

number=$(printf '%s' "$pr_json" | jq -r '.number')
states=$(printf '%s' "$pr_json" | jq -r '[.statusCheckRollup[]? | (.conclusion // .status // .state // "")] | join(",")')

if printf '%s' "$states" | grep -qiE 'failure|error|cancelled|timed_out'; then
  emit "Chief, PR #$number has a failing check."
  exit 0
fi
if printf '%s' "$states" | grep -qiE 'pending|in_progress|queued'; then
  emit "Chief, PR #$number checks are still running."
  exit 0
fi

mergeable=$(printf '%s' "$pr_json" | jq -r '.mergeStateStatus // empty')
if [ "$mergeable" = "DIRTY" ]; then
  emit "Chief, PR #$number has merge conflicts."
  exit 0
fi

# threads_checked stays empty (not "0") when the query itself failed or
# couldn't be paginated to completion, so a partial or failed lookup can't
# be mistaken for "confirmed zero unresolved threads" further down.
threads_checked=""
unresolved=0
owner_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$owner_repo" ]; then
  owner="${owner_repo%%/*}"
  repo="${owner_repo##*/}"
  review_threads_query='
    query($owner:String!,$repo:String!,$number:Int!,$cursor:String) {
      repository(owner:$owner, name:$repo) {
        pullRequest(number:$number) {
          reviewThreads(first: 100, after: $cursor) {
            nodes { isResolved }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }'
  cursor=""
  total=0
  ok=1
  pages=0
  while :; do
    pages=$((pages + 1))
    # Safety cap (100 * 20 = 2000 threads) so a pathological response can't
    # loop forever; treat hitting it as an incomplete, unverified check.
    if [ "$pages" -gt 20 ]; then
      ok=0
      break
    fi
    gh_args=(api graphql -f "query=$review_threads_query" -F "owner=$owner" -F "repo=$repo" -F "number=$number")
    [ -n "$cursor" ] && gh_args+=(-F "cursor=$cursor")
    graphql_json=$(gh "${gh_args[@]}" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$graphql_json" ]; then
      ok=0
      break
    fi
    # repository.pullRequest(number:...) is nullable in GitHub's schema even
    # though reviewThreads is non-null on the PullRequest type itself -- a
    # null pullRequest (transient hiccup, a race with the PR closing) makes
    # the whole nested path null with no GraphQL error, so gh still exits 0.
    # Validate the actual shape before trusting it as a real page of data,
    # instead of letting a null silently become "0 unresolved, no next page."
    shape_ok=$(printf '%s' "$graphql_json" | jq -r '
      (.data.repository.pullRequest.reviewThreads.nodes | type) == "array"
      and (.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage | type) == "boolean"
    ' 2>/dev/null)
    if [ "$shape_ok" != "true" ]; then
      ok=0
      break
    fi
    page_count=$(printf '%s' "$graphql_json" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)] | length' 2>/dev/null)
    if [ -z "$page_count" ]; then
      ok=0
      break
    fi
    total=$((total + page_count))
    has_next=$(printf '%s' "$graphql_json" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
    [ "$has_next" = "true" ] || break
    cursor=$(printf '%s' "$graphql_json" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // empty')
    if [ -z "$cursor" ]; then
      ok=0
      break
    fi
  done
  if [ "$ok" -eq 1 ]; then
    unresolved=$total
    threads_checked=1
  fi
fi

if [ -n "$threads_checked" ] && [ "$unresolved" -gt 0 ]; then
  emit "Chief, PR #$number still carries $unresolved open crack(s) from the last roast."
  exit 0
fi

# Only claim "clean and ready" when the unresolved-threads check actually
# succeeded -- a failed query defaulting to "assume clean" would be a false
# all-clear, worse than saying nothing.
if [ -n "$threads_checked" ] && [ "$mergeable" = "CLEAN" ]; then
  emit "Chief, PR #$number is green and clean; \`land\` is the next call."
  exit 0
fi

exit 0
