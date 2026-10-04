#!/usr/bin/env bash
# Local history with a merged topic branch but no GitHub remote, so there
# are no pull requests or review threads to read.
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
printf "const cache = new Map();\n" > cache.js
git add cache.js
git commit --quiet -m "feat(cache): add in-memory cache"
git switch --quiet main
git merge --quiet --no-ff -m "Merge branch 'feat/offline-cache'" feat/offline-cache
