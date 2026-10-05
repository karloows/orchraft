#!/usr/bin/env bash
# Clean main branch, nothing in flight, no GitHub remote.
set -euo pipefail

git init --quiet --initial-branch=main .
git config user.email "eval@example.com"
git config user.name "Eval Fixture"

printf "# checkout-service

Starts an HTTP listener on PORT.
" > README.md
git add README.md
git commit --quiet -m "docs(readme): describe the service"
