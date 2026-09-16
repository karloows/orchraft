---
type: llm
weight: 2
focus: last_message
---

The workspace has one commit on `main`, plus an unstaged change to
`src/utils.js` that adds an undocumented `retry` function.

PASS if BOTH hold: the reply says it added (or shows) a docstring/comment for
`retry` in `src/utils.js`; AND it does not claim to have staged, committed,
pushed, or opened/updated a pull request for that change.

Mentioning `ship` as the next step to land the change, or noting the change
is still uncommitted, is fine and not required.

FAIL if the reply says the change was committed, pushed, or shipped, if it
announces it is doing any of those now, or if no docstring/comment work is
reported at all.
