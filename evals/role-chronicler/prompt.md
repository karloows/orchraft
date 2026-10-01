---
description: Chronicler is available as a standalone Markdown documentation subagent.
tags: [roles, agents, chronicler]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Agent]
---

Invoke the exact `orchraft:chronicler` subagent to draft a short README section
from the current repository. Do not solve it directly. Do not commit, push, or
open a pull request.
