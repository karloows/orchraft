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
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
dirty=""
[ -n "$(git status --porcelain 2>/dev/null)" ] && dirty=1

if [[ "$branch" =~ ^(main|master)$ ]]; then
  [ -n "$dirty" ] && emit "Chief, \`$branch\` has uncommitted changes."
  exit 0
fi

if ! command -v gh >/dev/null 2>&1 || ! gh auth status >/dev/null 2>&1; then
  [ -n "$dirty" ] && emit "Chief, \`$branch\` has local changes (GitHub status unavailable)."
  exit 0
fi

pr_json=$(gh pr view "$branch" --json number,state,mergeStateStatus,statusCheckRollup 2>/dev/null) || pr_json=""

if [ -z "$pr_json" ] || [ "$(printf '%s' "$pr_json" | jq -r '.state')" != "OPEN" ]; then
  [ -n "$dirty" ] && emit "Chief, \`$branch\` has local changes and no open PR yet."
  exit 0
fi

number=$(printf '%s' "$pr_json" | jq -r '.number')
states=$(printf '%s' "$pr_json" | jq -r '[.statusCheckRollup[]? | (.conclusion // .state // "")] | join(",")')

if printf '%s' "$states" | grep -qiE 'failure|error|cancelled|timed_out'; then
  emit "Chief, PR #$number has a failing check."
  exit 0
fi
if printf '%s' "$states" | grep -qiE 'pending|in_progress|queued'; then
  emit "Chief, PR #$number checks are still running."
  exit 0
fi

owner_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || owner_repo=""
unresolved=0
if [ -n "$owner_repo" ]; then
  owner="${owner_repo%%/*}"
  repo="${owner_repo##*/}"
  unresolved=$(gh api graphql -f query='
    query($owner:String!,$repo:String!,$number:Int!) {
      repository(owner:$owner, name:$repo) {
        pullRequest(number:$number) {
          reviewThreads(first: 100) { nodes { isResolved } }
        }
      }
    }' -F owner="$owner" -F repo="$repo" -F number="$number" 2>/dev/null \
    | jq '[.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved==false)] | length' 2>/dev/null)
  unresolved=${unresolved:-0}
fi

if [ "$unresolved" -gt 0 ] 2>/dev/null; then
  emit "Chief, PR #$number still carries $unresolved open crack(s) from the last roast."
  exit 0
fi

mergeable=$(printf '%s' "$pr_json" | jq -r '.mergeStateStatus')
if [ "$mergeable" = "CLEAN" ]; then
  emit "Chief, PR #$number is green and clean; \`land\` is the next call."
  exit 0
fi

exit 0
