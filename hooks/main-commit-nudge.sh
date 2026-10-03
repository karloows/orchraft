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
# It deliberately does not read baseBranch from the config file: that would
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

# Establish relevance before inspecting the command at all: this hook has
# nothing to say about a Bash call outside a git repository, so it exits
# here instead of reading tool_input.command for one. Every Bash call still
# reaches this script -- matcher "Bash" has no narrower selector Claude Code
# offers -- but a non-git cwd never gets its command text examined.
# Check the printed result, not just the exit status: a bare repository
# prints "false" but still exits 0, so an exit-status-only check would
# wrongly treat it as a work tree and fall through to command matching.
[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = true ] || exit 0

command_str=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$command_str" ] || exit 0

# Match "git commit" or "git push" as their own words, not a substring of
# something else (e.g. a script path containing "git-commit-helper"). An
# optional "-C <dir>" (bare, or a quoted path) between git and the
# subcommand still counts.
dir_re='("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:];&|]+)'
printf '%s' "$command_str" | grep -qE '(^|[;&|]|[[:space:]])git([[:space:]]+-C[[:space:]]+'"$dir_re"')?[[:space:]]+(commit|push)([[:space:];&|]|$)' || exit 0

# cwd is the session's directory, not necessarily where the git command
# runs: "cd <worktree> && git commit" or "git -C <worktree> commit" commits
# in another checkout, and reading cwd's branch there fired a false nudge on
# every commit from a linked worktree while the session sat on main. Follow
# a leading "cd <dir>" ending in && or ;, then a "git -C <dir>" (relative to
# that cd, as the shell would), with a quoted path and ~ handled. Anything
# else -- pushd, subshells, a cd later in the chain, variables in the path,
# other git global options before -C -- is deliberately not parsed and falls
# back to cwd; this is a nudge, not a shell interpreter. One resolved target
# stands for the whole command, so a chain mixing "git -C <dir> commit" with
# a bare "git push" is judged by the -C target alone. A non-git cwd already
# exited above, so none of this runs from one. A target that does not
# resolve to a git work tree exits silently, except a failed "cd <dir>;",
# which falls back to cwd because the git command still runs there.
# "git -C" only counts at the start of a command (string start or after a
# separator), so "git commit -m 'fix git -C x push'" isn't read as a target.
cd_re='^[[:space:]]*cd[[:space:]]+'"$dir_re"'[[:space:]]*(&&|;)'
git_c_re='(^|[;&|])[[:space:]]*git[[:space:]]+-C[[:space:]]+'"$dir_re"'[[:space:]]+(commit|push)([[:space:];&|]|$)'
enter() {
  local dir=$1 sep=${2:-}
  # Expand ~ before unquoting: the shell leaves a quoted "~/x" literal.
  case $dir in "~" | "~/"*) dir="$HOME${dir#\~}" ;; esac
  dir=${dir#[\"\']}
  dir=${dir%[\"\']}
  # git -C ignores an empty path and never consults CDPATH; a shell cd does.
  if [ "$sep" = "-C" ]; then
    [ -n "$dir" ] || return
    dir=$(CDPATH='' cd -- "$dir" 2>/dev/null && pwd) || exit 0
  fi
  if ! cd "$dir" 2>/dev/null; then
    # After a failed "cd <dir>;" the shell still runs the git command, in the
    # original directory, so keep judging cwd. After "&&" it never runs.
    [ "$sep" = ";" ] && return
    exit 0
  fi
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = true ] || exit 0
}
if [[ $command_str =~ $cd_re ]]; then enter "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"; fi
if [[ $command_str =~ $git_c_re ]]; then enter "${BASH_REMATCH[2]}" -C; fi

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
