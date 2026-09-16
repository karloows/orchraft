---
type: llm
weight: 2
focus: last_message
---

The workspace is an empty directory: there is no git repository, no branch,
and no open pull request.

PASS if the reply reports that it cannot review because there is no pull
request (or no repository) to review, AND tells the user to run the ship
workflow, or otherwise open a pull request, first.

FAIL if the reply omits that next step, invents findings about code, claims to
have posted a review or comment, or reports a successful review.
