#!/usr/bin/env bash
# Builds a small repo on a topic branch so the case can actually commit.
set -euo pipefail

git init --quiet --initial-branch=main .
git config user.email "eval@example.com"
git config user.name "Eval Fixture"

cat > README.md <<'DOC'
# checkout-service

Starts an HTTP listener on the port named by PORT.

## Configuration

- `PORT`: the port to bind. Defaults to 8080.
DOC

git add README.md
git commit --quiet -m "docs(readme): describe the service"
git switch --quiet -c docs/troubleshooting-section
