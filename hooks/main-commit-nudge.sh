#!/usr/bin/env bash
# PreToolUse hook, matcher "Bash". Nudges (never blocks) when a git commit or
# push is about to run directly against the repository's integration branch
# -- the one bypass ship's own Guardrails single out ("Never commit or push
# directly to the base branch unless the user explicitly asks"). Deliberately
# scoped to that branch only, not every commit: a broader version would fire
# on ship's own legitimate commits far more often than it would ever catch a
# real bypass, which is exactly the noise watchtower's own file warns an
# ambient check can become.
#
# The branch comes from origin/HEAD, so a repository whose default is
# develop is covered without this script learning to parse the config file.
# It deliberately does not read baseBranch from .orchraft.json: that would
# mean a second copy of the JSONC comment-stripping in watchtower-nudge.sh,
# and two copies of a parser drift. A repo whose default branch and
# baseBranch differ gets the nudge for the default branch only.
# Always permissionDecision "allow" -- a reminder injected into context, not
# a permission prompt shown to the user, since blocking would override a
# user's explicit intent to commit to that branch directly.
set -uo pipefail

emit() {
  jq -n --arg ctx "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",additionalContext:$ctx}}'
  exit 0
}

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
if [ -n "$cwd" ] && ! cd "$cwd" 2>/dev/null; then
  exit 0
fi

command_str=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$command_str" ] || exit 0

# Match "git commit" or "git push" as their own words, not a substring of
# something else (e.g. a script path containing "git-commit-helper").
printf '%s' "$command_str" | grep -qE '(^|[;&|]|[[:space:]])git[[:space:]]+(commit|push)([[:space:]]|$)' || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0

# origin/HEAD names the repository's default branch when the remote ref
# exists; fall back to the conventional names when it does not (no remote,
# a fresh clone that never fetched it, a detached setup).
default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
default_branch="${default_branch#origin/}"

if { [ -n "$default_branch" ] && [ "$branch" = "$default_branch" ]; } ||
   { [ -z "$default_branch" ] && [[ "$branch" =~ ^(main|master)$ ]]; }; then
  emit "Chief, that git command targets \`$branch\` directly -- \`ship\` is the usual path for a branch/commit/PR. Proceeding only if you meant this."
fi

exit 0
