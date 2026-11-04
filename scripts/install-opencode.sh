#!/usr/bin/env bash
# Install orchraft into a project for opencode: skills, policies, and the agents converted to opencode's format.
# Skills are orchraft-owned and refreshed on every run. Policies and agents may
# be customised or hand-written in the target, so an existing file is kept.
# Usage: scripts/install-opencode.sh <target-project-dir>
set -euo pipefail
src=$(cd "$(dirname "$0")/.." && pwd)
dst=${1:?usage: install-opencode.sh <target-project-dir>}
# A misspelled path must fail, not be created by mkdir -p below.
[ -d "$dst" ] || { echo "target directory does not exist: $dst" >&2; exit 1; }

# copy_new <from> <to>: copy unless <to> already exists.
copy_new() {
  if [ -e "$2" ]; then echo "kept existing $2"; return; fi
  mkdir -p "$(dirname "$2")"
  # Write beside the target, then link into place only if it is still absent, so
  # an interrupted copy never leaves a partial file that later runs call "kept".
  # cat, not cp: a mktemp source is 0600 and cp would carry that mode over.
  # mktemp creates the file exclusively, so a planted symlink is never followed;
  # it is 0600, so restore the mode a plain write would get, capped at 0644 so a
  # permissive umask never makes an installed file group- or world-writable.
  part=$(mktemp "$2.part.XXXXXX") || return 1
  chmod "$(printf '%o' $((0644 & ~$(umask))))" "$part" || { rm -f "$part"; return 1; }
  # Callers use "|| exit 1", which turns set -e off in here, so check each step.
  cat "$1" > "$part" || { rm -f "$part"; return 1; }
  if ! ln "$part" "$2" 2>/dev/null; then
    if [ -e "$2" ] || [ -L "$2" ]; then
      echo "kept existing $2"
    else
      echo "failed to install $2" >&2
      rm -f "$part"
      return 1
    fi
  fi
  rm -f "$part"
}

# The skills directory and its parent must be real directories too, or cp -R
# would copy through the link into wherever it points.
# The same goes for every other directory it writes into: .opencode/agents and
# the context tree (each directory orchraft's context/ has, since copy_new
# would otherwise write through a linked context/policies).
check_dirs() {
  while IFS= read -r d; do
    if [ -L "$d" ]; then echo "refusing to install through symlink $d" >&2; exit 1; fi
  done
}
{
  printf '%s\n' "$dst/.agents" "$dst/.agents/skills" "$dst/.opencode" "$dst/.opencode/agents" "$dst/context"
  (cd "$src/context" && find . -mindepth 1 -type d) | while IFS= read -r d; do printf '%s\n' "$dst/context/${d#./}"; done
} | check_dirs
mkdir -p "$dst/.agents/skills" "$dst/.opencode/agents"
# Refuse to write through a symlink where an orchraft skill file or directory
# belongs: cp and the rewrite below would follow it into the user's own files.
(cd "$src/skills" && find . -mindepth 1 -print) | while read -r f; do
  if [ -L "$dst/.agents/skills/${f#./}" ]; then
    echo "refusing to overwrite symlink $dst/.agents/skills/${f#./}" >&2; exit 1
  fi
done
# Unlink each file orchraft ships first, so cp creates a fresh one: a skill file
# hard-linked to another project's would otherwise be overwritten through the link.
(cd "$src/skills" && find . -type f) | while read -r f; do
  rm -f "$dst/.agents/skills/${f#./}"
done
cp -R "$src/skills/." "$dst/.agents/skills/"
# Skills cite each other as skills/<name>/SKILL.md; point those at the installed
# path, and shaman's plugin-package wording at the installed skills directory.
# Only the files just copied are touched, never a skill the user added.
rw_tmp=$(mktemp)
for f in "$src"/skills/*/SKILL.md; do
  t="$dst/.agents/skills/${f#"$src"/skills/}"
  sed -E 's#skills/([a-z-]+)/SKILL\.md#.agents/skills/\1/SKILL.md#g; s# and the orchraft plugin root##g; s#the loaded orchraft package contains `skills/` and#`.agents/skills/` contains#g; s#inspect the package for the other#inspect `.agents/skills/` for the other#g' "$t" > "$rw_tmp"
  rm -f "$t" && cat "$rw_tmp" > "$t"
done
rm -f "$rw_tmp"
(cd "$src/context" && find . -type f ! -name .DS_Store) | while read -r f; do
  copy_new "$src/context/${f#./}" "$dst/context/${f#./}" || exit 1
done

# Claude agent -> opencode agent: drop name/tools/skills, add mode, and deny
# edits when the Claude tool list had no Edit/Write. Body is kept verbatim
# except skill paths and the plugin-qualified agent names (orchraft:forgehand
# -> forgehand), which are plain names once installed this way.
# Read-only agents ask before any shell command outside this list. File reads
# (cat, grep, ...) are left out: they have the read tools, and a shell read
# would skip opencode's ask on .env files. Any agent
# without the Agent tool in its Claude tool list cannot delegate, so it gets
# task: deny whether or not it can edit. A guardrail, not a sandbox: an
# allowed command can still redirect output, so the agent text stays the rule.
# warpath is the one agent that delegates (to forgehand and trialmaster). It is
# a subagent here, and opencode's default experimental.subagent_depth of 1 stops
# a subagent from starting another, so the user must set it to 2 in their own
# opencode config. This script never edits that config.
readonly_bash=$(for c in "git status" "git log" "git show" \
  "git branch --show-current" "git branch --list" "git rev-parse" \
  "git remote -v" "git remote get-url" "git ls-files" "gh pr view" \
  "gh pr list" "gh pr checks" "gh pr diff" ls; do
  printf '    "%s *": allow\n' "$c"; done)

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
for f in "$src"/agents/*.md; do
  grep -E '^tools:.*(Edit|Write)' "$f" >/dev/null && rw=1 || rw=0
  grep -E '^tools:.*Agent' "$f" >/dev/null && del=1 || del=0
  ro="$readonly_bash" awk -v rw="$rw" -v del="$del" '
    /^---$/ && n < 2 { n++
      if (n == 2) { print "mode: subagent"
        if (rw == 0 || del == 0) print "permission:"
        if (rw == 0) print "  edit: deny"
        if (del == 0) print "  task: deny"
        if (rw == 0) { print "  bash:\n    \"*\": ask"; print ENVIRON["ro"] } }
      print; next }
    n == 1 && !/^description:/ { next }
    { print }
  ' "$f" | sed -E 's#skills/#.agents/skills/#g; s#orchraft:([a-z-]+)#\1#g' > "$tmp"
  copy_new "$tmp" "$dst/.opencode/agents/$(basename "$f")" || exit 1
done
echo "note: read-only agents' shell rules come after your project rules in opencode, so they override a project shell deny; re-add hard denies in .opencode/agents/*.md."
echo "note: warpath delegates to forgehand and trialmaster, so set experimental.subagent_depth to 2 in your opencode config (default 1)."
