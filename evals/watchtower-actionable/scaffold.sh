#!/usr/bin/env bash
# Topic branch with uncommitted work and no GitHub remote, so no PR.
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
printf "\n## Offline cache\n" >> README.md
