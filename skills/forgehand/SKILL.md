---
name: forgehand
description: Have the AI implement a requested code change and run focused validation without committing, pushing, or changing GitHub. Use when the user asks to fix, build, refactor, or test code.
---

# Forgehand Workflow

Use this skill for implementation work that should stay in the working tree.

## Command Card

| Goal | Preferred tool/command | Notes |
| --- | --- | --- |
| Understand scope | `read`, `glob`, `grep`, `git status --short` | Read only files relevant to the request. |
| Implement | `edit`/`write` | Smallest correct change; preserve unrelated work. |
| Validate | Narrowest relevant test/lint/build command | Report exact command and result. |

**Fast Path / Do Not**
- Do not commit, push, branch, open/update PRs, post reviews, change issues, release, or merge.
- Do not scan the whole repo when targeted reads answer the question.
- If planning is needed, direct to `warplan`; if shipping is requested, direct to `ship`.
