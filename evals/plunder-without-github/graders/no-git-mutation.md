---
type: tool_used
weight: 1
tool: Bash
input_match: "(git (add|commit|push|rebase|reset)\\b|git merge([^-]|$)|git switch -[cC]|git switch --create|git checkout -[bB]|git checkout --(branch|orphan)|git branch [^-]|gh pr (create|edit|merge|comment|review|close|reopen)|gh issue (create|edit|comment|close|reopen)|gh api .*(-X|--method)[ =]?(POST|PATCH|PUT|DELETE)|resolveReviewThread|addPullRequestReview)"
min: 0
max: 0
---
