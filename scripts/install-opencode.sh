#!/usr/bin/env bash
# Install orchraft into a project for OpenCode: skills, context, and the agents
# converted to OpenCode's format. Everything lands under .opencode/ so the
# project keeps a single OpenCode-owned directory.
# Skill files orchraft ships are overwritten on every run; stale ones from older revisions are left. Context and agents may
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
  local part
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

# The skills directories and their parents must be real directories too, or
# writes would copy through a link into wherever it points. The same goes for
# every other directory this script writes into: .opencode/agents, the
# .opencode/context tree, and the .agents/skills compatibility copy.
check_dirs() {
  while IFS= read -r d; do
    if [ -L "$d" ]; then echo "refusing to install through symlink $d" >&2; exit 1; fi
  done
}
{
  printf '%s\n' "$dst/.agents" "$dst/.agents/skills" "$dst/.opencode" "$dst/.opencode/skills" "$dst/.opencode/agents" "$dst/.opencode/plugins" "$dst/.opencode/hooks" "$dst/.opencode/context"
  (cd "$src/context" && find . -mindepth 1 -type d) | while IFS= read -r d; do printf '%s\n' "$dst/.opencode/context/${d#./}"; done
} | check_dirs
mkdir -p "$dst/.agents/skills" "$dst/.opencode/skills" "$dst/.opencode/agents" "$dst/.opencode/plugins" "$dst/.opencode/hooks" "$dst/.opencode/context"
# Refuse to write through a symlink where an orchraft skill file or directory
# belongs: the writes below would follow it into the user's own files.
(cd "$src/skills" && find . -mindepth 1 -print) | while read -r f; do
  for root in "$dst/.opencode/skills" "$dst/.agents/skills"; do
    if [ -L "$root/${f#./}" ]; then
      echo "refusing to overwrite symlink $root/${f#./}" >&2; exit 1
    fi
  done
done
# Skills cite each other as skills/<name>/SKILL.md; point those at the installed
# path, and shaman's plugin-package wording at the installed skills directory.
# Only files orchraft ships are written, never a skill the user added. Each one
# is staged in a sibling file and renamed into place, so a failed copy leaves the
# previous install intact and a hard link to another project's file is replaced,
# not written through.
# Install into .opencode/skills (OpenCode-native) and .agents/skills (cross-agent
# compatibility). Both get the same content with path refs rewritten for their
# location; context refs point at .opencode/context in both.
install_skill_file() {
  local srcfile=$1 rel=$2 root=$3 label=$4
  local t="$root/$rel"
  local part
  part=$(mktemp "$t.part.XXXXXX") || return 1
  if [ "${rel##*/}" = SKILL.md ]; then
    sed -E \
      -e "s#skills/([a-z-]+)/SKILL\\.md#${label}/\\1/SKILL.md#g" \
      -e "s# and the orchraft plugin root##g" \
      -e "s#the loaded orchraft package contains \`skills/\` and#\`${label}\` contains#g" \
      -e "s#inspect the package for the other#inspect \`${label}\` for the other#g" \
      -e 's#(^|[^A-Za-z0-9_$/{])context/(policies|formats|personality\.md)#\1.opencode/context/\2#g' \
      "$srcfile" > "$part"
  else
    cat "$srcfile" > "$part"
  fi || { rm -f "$part"; return 1; }
  # mktemp files are 0600: give the file the mode a plain write would get, capped at 0644.
  chmod "$(printf '%o' $((0644 & ~$(umask))))" "$part" && mv -f "$part" "$t" || { rm -f "$part"; return 1; }
}
(cd "$src/skills" && find . -mindepth 1 -type d) | while read -r d; do
  mkdir -p "$dst/.opencode/skills/${d#./}" "$dst/.agents/skills/${d#./}" || exit 1
done
(cd "$src/skills" && find . -type f) | while read -r f; do
  rel=${f#./}
  install_skill_file "$src/skills/$rel" "$rel" "$dst/.opencode/skills" ".opencode/skills" || exit 1
  install_skill_file "$src/skills/$rel" "$rel" "$dst/.agents/skills" ".agents/skills" || exit 1
done
(cd "$src/context" && find . -type f ! -name .DS_Store) | while read -r f; do
  part=$(mktemp) || exit 1
  sed -E \
    -e 's#skills/([a-z-]+)/SKILL\.md#.opencode/skills/\1/SKILL.md#g' \
    -e 's#(^|[^A-Za-z0-9_$/{])context/(policies|formats|personality\.md)#\1.opencode/context/\2#g' \
    "$src/context/${f#./}" > "$part" || { rm -f "$part"; exit 1; }
  copy_new "$part" "$dst/.opencode/context/${f#./}" || { rm -f "$part"; exit 1; }
  rm -f "$part"
done

# Port of hooks/hooks.json: scripts/opencode-plugin/orchraft-hooks.js shells
# out to copies of hooks/*.sh placed alongside it at .opencode/hooks/, so the
# state checks stay one source of truth across both hosts. Orchraft-shipped,
# like skills: overwritten every run, not kept like a policy or agent file.
for f in watchtower-nudge.sh main-commit-nudge.sh; do
  t="$dst/.opencode/hooks/$f"
  part=$(mktemp "$t.part.XXXXXX") || exit 1
  cat "$src/hooks/$f" > "$part" || { rm -f "$part"; exit 1; }
  chmod "$(printf '%o' $((0755 & ~$(umask))))" "$part" && mv -f "$part" "$t" || { rm -f "$part"; exit 1; }
done
t="$dst/.opencode/plugins/orchraft-hooks.js"
part=$(mktemp "$t.part.XXXXXX") || exit 1
cat "$src/scripts/opencode-plugin/orchraft-hooks.js" > "$part" || { rm -f "$part"; exit 1; }
chmod "$(printf '%o' $((0644 & ~$(umask))))" "$part" && mv -f "$part" "$t" || { rm -f "$part"; exit 1; }

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
  ' "$f" | sed -E \
    -e 's#skills/#.opencode/skills/#g' \
    -e 's#(^|[^A-Za-z0-9_$/{])context/(policies|formats|personality\.md)#\1.opencode/context/\2#g' \
    -e 's#orchraft:([a-z-]+)#\1#g' > "$tmp"
  copy_new "$tmp" "$dst/.opencode/agents/$(basename "$f")" || exit 1
done
if [ -d "$dst/context/policies" ] && [ -f "$dst/context/policies/approval-policy.md" ]; then
  echo "note: found project-root context/ (old OpenCode copy-install layout). This install uses .opencode/context/; review and remove the old context/ copy if it is only an orchraft install artifact."
fi
echo "note: read-only agents' shell rules come after your project rules in opencode, so they override a project shell deny; re-add hard denies in .opencode/agents/*.md."
echo "note: warpath delegates to forgehand and trialmaster, so set experimental.subagent_depth to 2 in your opencode config (default 1)."
echo "note: .opencode/plugins/orchraft-hooks.js ports the watchtower and main-branch-commit nudges; both need jq on PATH, same as the Claude Code hooks."
