#!/usr/bin/env bash
# Fails when a doc or manifest that restates the skill inventory drifts from
# skills/, the canonical one. Only lists meant to name every skill are
# checked; partial lists (role agents, read-only examples, personality
# sections) are deliberately left out. Each roster is located by a start and
# end line pattern, so renaming one of those anchors fails the check loudly
# instead of silently skipping it.
# Usage: scripts/check-rosters.sh [repo-root]
set -uo pipefail
cd "${1:-$(dirname "$0")/..}" || exit 2
command -v jq >/dev/null || { echo "check-rosters: jq is required" >&2; exit 2; }

expected=$(for d in skills/*/SKILL.md; do basename "$(dirname "$d")"; done | sort)
count=$(printf '%s\n' "$expected" | wc -l | tr -d ' ')
status=0

fail() { echo "roster drift: $*" >&2; status=1; }

# check <file> <label> <start-regex> <end-regex> <name-regex>
# Names are the skill tokens matched by <name-regex> between the first
# <start-regex> line and the next <end-regex> line.
check() {
  local file=$1 label=$2 start=$3 end=$4 pat=$5 line names found
  line=$(grep -nE "$start" "$file" | head -1 | cut -d: -f1)
  if [ -z "$line" ]; then
    fail "$file: $label not found (no line matches /$start/)"
    return
  fi
  # Without its end line the range would run to end of file and could still
  # match, so a renamed end anchor fails as loudly as a renamed start.
  if ! awk -v l="$line" -v e="$end" 'NR > l && $0 ~ e {f=1; exit} END {exit !f}' "$file"; then
    fail "$file: $label end not found (no line after $line matches /$end/)"
    return
  fi
  names=$(awk -v l="$line" -v e="$end" 'NR >= l {print} NR > l && $0 ~ e {exit}' "$file" |
    grep -oE "$pat" | sed -E 's/[^a-z-]+$//; s/.*[^a-z-]//' | sort)
  found=$(uniq <<< "$names")
  uniq -d <<< "$names" | while read -r n; do
    [ -n "$n" ] && echo "roster drift: $file:$line: $label lists '$n' more than once" >&2
  done
  [ "$names" = "$found" ] || status=1
  comm -23 <(echo "$expected") <(echo "$found") | while read -r n; do
    [ -n "$n" ] && echo "roster drift: $file:$line: $label is missing skill '$n'" >&2
  done
  comm -13 <(echo "$expected") <(echo "$found") | while read -r n; do
    [ -n "$n" ] && echo "roster drift: $file:$line: $label names '$n', which has no skills/$n/SKILL.md" >&2
  done
  [ "$found" = "$expected" ] || status=1
}

check README.md "skill table" '^## The War Band So Far' '^## Developer Roles' '^\| `[a-z-]+`'
check README.md "/orchraft: load list" 'The skills load as' 'They read' '/orchraft:[a-z-]+'
check README.md "Copy Into A Project skills list" 'for the canonical' 'workflows\.' '`[a-z-]+`'
check AGENTS.md "intro skill list" 'current skills cover' 'more workflows' '`[a-z-]+`'
check AGENTS.md "Skills section" '^## Skills' '^## Role Agents' 'skills/[a-z-]+/'
check AGENTS.md "/orchraft: list" 'installed users get' 'files\.$' '/orchraft:[a-z-]+'
check CONTRIBUTING.md "skill table" 'skills that ship today' '^Each skill' '^\| `[a-z-]+`'
check .github/ISSUE_TEMPLATE/bug_report.yml "component dropdown" 'id: component' 'validations:' '^ +- [a-z-]+$'

# Skill counts such as the README badge ("skills-18", "18 skills") or prose
# like "a full 18-skill catalog".
counts=$(grep -noE 'skills-[0-9]+|[0-9]+ skills|[0-9]+-skill' README.md AGENTS.md CONTRIBUTING.md)
while IFS=: read -r file line match; do
  [ -n "$match" ] && [ "${match//[^0-9]/}" != "$count" ] &&
    fail "$file:$line: skill count '$match' should be $count"
done <<< "$counts"

# Manifests and marketplace files name no skills; the ones that declare a
# skills path must still point at the canonical directory.
for f in plugin.json .*-plugin/*.json; do
  s=$(jq -r '.skills // empty' "$f") || { fail "$f: not valid JSON"; continue; }
  [ -z "$s" ] || [ "$s" = "./skills/" ] || fail "$f: skills path is '$s', expected './skills/'"
done

[ "$status" = 0 ] && echo "rosters match skills/ ($count skills)"
exit "$status"
