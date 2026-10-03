---
type: llm
weight: 2
focus: last_message
---

The workspace is a git repository with no remote. The current branch is
`feat/offline-cache`, which has uncommitted changes (a new `cache.js` and an
edited `README.md`) and no pull request.

PASS if ALL hold: the reply surfaces that `feat/offline-cache` has
uncommitted or local work that is not yet in a pull request; it is short (a
nudge of a few lines at most, not a long report); AND it does not claim to
have committed, pushed, or opened a pull request. Naming `ship` as the
likely next step is fine.

FAIL if the reply says nothing is in flight, invents a pull request number,
check results, or review findings, or says it shipped the work.
