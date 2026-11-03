#!/usr/bin/env bash
# Install orchraft into a project for opencode: skills, policies, and the agents converted to opencode's format.
# Skills are orchraft-owned and refreshed on every run. Policies and agents may
# be customised or hand-written in the target, so an existing file is kept.
# Usage: scripts/install-opencode.sh <target-project-dir>
set -euo pipefail
src=$(cd "$(dirname "$0")/.." && pwd)
dst=${1:?usage: install-opencode.sh <target-project-dir>}

# copy_new <from> <to>: copy unless <to> already exists.
copy_new() {
  if [ -e "$2" ]; then echo "kept existing $2"; return; fi
  mkdir -p "$(dirname "$2")"
  # Write beside the target, then link into place only if it is still absent, so
  # an interrupted copy never leaves a partial file that later runs call "kept".
  # cat, not cp: a mktemp source is 0600 and cp would carry that mode over.
  # mktemp creates the file exclusively, so a planted symlink is never followed;
  # it is 0600, so restore the mode the umask would have given a plain write.
  part=$(mktemp "$2.part.XXXXXX") || return 1
  chmod "$(printf '%o' $((0666 & ~$(umask))))" "$part" || { rm -f "$part"; return 1; }
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

mkdir -p "$dst/.agents/skills" "$dst/.opencode/agents"
# Refuse to write through a symlink where an orchraft skill file or directory
# belongs: cp and the rewrite below would follow it into the user's own files.
(cd "$src/skills" && find . -mindepth 1 -print) | while read -r f; do
  if [ -L "$dst/.agents/skills/${f#./}" ]; then
    echo "refusing to overwrite symlink $dst/.agents/skills/${f#./}" >&2; exit 1
  fi
done
cp -R "$src/skills/." "$dst/.agents/skills/"
# Skills cite each other as skills/<name>/SKILL.md; point those at the installed
# path, and shaman's plugin-package wording at the installed skills directory.
# Only the files just copied are touched, never a skill the user added.
rw_tmp=$(mktemp)
for f in "$src"/skills/*/SKILL.md; do
  t="$dst/.agents/skills/${f#"$src"/skills/}"
  sed -E 's#skills/([a-z-]+)/SKILL\.md#.agents/skills/\1/SKILL.md#g; s# and the orchraft plugin root##g; s#the loaded orchraft package contains `skills/` and#`.agents/skills/` contains#g; s#inspect the package for the other#inspect `.agents/skills/` for the other#g' "$t" > "$rw_tmp"
  cat "$rw_tmp" > "$t"
done
rm -f "$rw_tmp"
(cd "$src/context" && find . -type f ! -name .DS_Store) | while read -r f; do
  copy_new "$src/context/${f#./}" "$dst/context/${f#./}" || exit 1
done

# Claude agent -> opencode agent: drop name/tools/skills, add mode, and deny
# edits when the Claude tool list had no Edit/Write. Body is kept verbatim
# except skill paths and the plugin-qualified agent names (orchraft:forgehand
# -> forgehand), which are plain names once installed this way.
# Read-only agents ask before any shell command outside this list. Any agent
# without the Agent tool in its Claude tool list cannot delegate, so it gets
# task: deny whether or not it can edit. A guardrail, not a sandbox: an
# allowed command can still redirect output, so the agent text stays the rule.
# warpath is the one agent that delegates (to forgehand and trialmaster). It is
# a subagent here, and opencode's default experimental.subagent_depth of 1 stops
# a subagent from starting another, so the user must set it to 2 in their own
# opencode config. This script never edits that config.
readonly_bash=$(for c in "git status" "git log" "git diff" "git show" \
  "git branch --show-current" "git branch --list" "git rev-parse" \
  "git remote -v" "git remote get-url" "git ls-files" "gh pr view" \
  "gh pr list" "gh pr checks" "gh pr diff" ls cat grep rg head tail wc jq; do
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
echo "note: warpath delegates to forgehand, so set experimental.subagent_depth to 2 in your opencode config (default 1)."
