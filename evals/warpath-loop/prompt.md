---
description: Warpath repeats review cycles and stops only after a clean latest head.
tags: [warpath, orchestration, review-loop]
runs: 3
max_turns: 16
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Run the Warpath loop on this pull request. Delegate fixes to Forgehand, ship
the changes, and roast the new pull-request head again. Do not stop merely
because a ship completed; stop only when the latest roast reports zero
findings. Do not merge the pull request.
