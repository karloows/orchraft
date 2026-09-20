#!/usr/bin/env bash
# PreToolUse hook, matcher "Bash". Nudges (never blocks) when a git commit or
# push is about to run directly against main/master -- the one bypass ship's
# own Guardrails single out ("Never commit or push directly to main unless
# the user explicitly asks"). Deliberately scoped to main/master only, not
# every commit: a broader version would fire on ship's own legitimate
# commits far more often than it would ever catch a real bypass, which is
# exactly the noise watchtower's own file warns an ambient check can become.
# Always permissionDecision "allow" -- a reminder injected into context, not
# a permission prompt shown to the user, since blocking would override a
# user's explicit intent to commit to main directly.
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

if [[ "$branch" =~ ^(main|master)$ ]]; then
  emit "Chief, that git command targets \`$branch\` directly -- \`ship\` is the usual path for a branch/commit/PR. Proceeding only if you meant this."
fi

exit 0
