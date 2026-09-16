#!/usr/bin/env bash
# Builds a small repo with an undocumented function sitting in the working
# tree diff, so the case can actually add lore to it.
set -euo pipefail

git init --quiet --initial-branch=main .
git config user.email "eval@example.com"
git config user.name "Eval Fixture"

mkdir -p src
cat > src/utils.js <<'DOC'
/** Adds two numbers. */
function add(a, b) {
  return a + b;
}

module.exports = { add };
DOC

git add src/utils.js
git commit --quiet -m "feat(utils): add add helper"

cat > src/utils.js <<'DOC'
/** Adds two numbers. */
function add(a, b) {
  return a + b;
}

function retry(fn, maxAttempts) {
  let lastErr;
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return fn();
    } catch (err) {
      lastErr = err;
    }
  }
  throw lastErr;
}

module.exports = { add, retry };
DOC
