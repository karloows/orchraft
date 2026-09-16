---
type: llm
weight: 2
focus:
  source: file
  path: src/utils.js
---

This is the actual post-run content of `src/utils.js`.

PASS if the `retry` function has a docstring/comment directly above its
signature, in the same style as the existing `add` function's comment
(e.g. a `/** ... */` block).

FAIL if `retry` has no comment immediately above it, or the file is
otherwise unchanged from having only an `add` function.
