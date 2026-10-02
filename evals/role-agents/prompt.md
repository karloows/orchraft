---
description: Orc role requests delegate to standalone Claude Code subagents.
tags: [roles, agents, forgehand, trialmaster]
runs: 3
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Invoke the exact `orchraft:trialmaster` subagent to review this pull request.
Do not solve it directly. Do not post a review or change any files.
