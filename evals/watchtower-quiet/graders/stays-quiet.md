---
type: llm
weight: 2
focus: last_message
---

The workspace is a git repository with no remote, checked out on a clean
`main` branch: no topic branch, no uncommitted changes, and no pull request.
Nothing is actionable.

PASS if the reply is brief and conveys that there is nothing to act on (for
example "nothing in flight", "all quiet", or an empty or near-empty
response).

FAIL if the reply invents work in flight, such as a pull request, failing
checks, review findings, or uncommitted changes; if it recommends shipping,
roasting, or landing something; or if it pads the answer into a long status
report.
