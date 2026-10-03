#!/usr/bin/env bash
# Topic branch two commits ahead of main, clean tree, no GitHub remote.
set -euo pipefail

git init --quiet --initial-branch=main .
git config user.email "eval@example.com"
git config user.name "Eval Fixture"

printf "# checkout-service

Starts an HTTP listener on PORT.
" > README.md
git add README.md
git commit --quiet -m "docs(readme): describe the service"

git switch --quiet -c feat/offline-cache
printf "const cache = new Map();\nmodule.exports = { cache };\n" > cache.js
git add cache.js
git commit --quiet -m "feat(cache): add in-memory cache"
printf "\n## Offline cache\n\nResponses are cached in memory.\n" >> README.md
git add README.md
git commit --quiet -m "docs(readme): describe offline cache"
