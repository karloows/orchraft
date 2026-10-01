---
name: forgehand
description: Have the AI implement a requested code change and run focused validation without committing, pushing, or changing GitHub. Use when the user asks to fix, build, refactor, or test code.
---

# Forgehand Workflow

Use this skill for implementation work that should stay in the working tree.

## Rules

- Read the repository's instructions, relevant policies, and existing code
  before editing.
- Trace the real flow and reuse existing helpers and patterns.
- Make the smallest correct change and preserve unrelated work.
- Run the narrowest useful validation after editing.
- Stop before committing, pushing, creating or updating branches, opening or
  updating pull requests, posting reviews, changing issues, publishing
  releases, or merging.
- Report the files changed and validation results honestly.

If the work needs a plan first, stop and direct the user to `warplan`. If the
user wants the completed work shipped, stop and direct them to `ship`.
