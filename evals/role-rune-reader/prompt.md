---
description: Rune-Reader is available as a standalone status subagent.
tags: [roles, agents, rune-reader]
runs: 1
max_turns: 10
allowed_tools: [Read, Glob, Grep, Agent]
---

Invoke the exact `orchraft:rune-reader` subagent to report the current branch
and review status. Do not solve it directly. Do not edit files or mutate git
or GitHub.
