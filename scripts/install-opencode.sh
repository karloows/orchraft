#!/usr/bin/env bash
# Install orchraft into a project for opencode: skills, policies, and the agents converted to opencode's format.
# Usage: scripts/install-opencode.sh <target-project-dir>
set -euo pipefail
src=$(cd "$(dirname "$0")/.." && pwd)
dst=${1:?usage: install-opencode.sh <target-project-dir>}

mkdir -p "$dst/.agents" "$dst/.opencode/agents"
mkdir -p "$dst/.agents/skills"
cp -R "$src/skills/." "$dst/.agents/skills/"
cp -R "$src/context" "$dst/"

# Claude agent -> opencode agent: drop name/tools/skills, add mode, and deny
# edits when the Claude tool list had no Edit/Write. Body is kept verbatim.
for f in "$src"/agents/*.md; do
  grep -E '^tools:.*(Edit|Write)' "$f" >/dev/null && rw=1 || rw=0
  awk -v rw="$rw" '
    /^---$/ && n < 2 { n++
      if (n == 2) { print "mode: subagent"; if (rw == 0) print "permission:\n  edit: deny" }
      print; next }
    n == 1 && !/^description:/ { next }
    { print }
  ' "$f" | sed 's#skills/#.agents/skills/#g' > "$dst/.opencode/agents/$(basename "$f")"
done
