---
type: tool_used
weight: 1
tool: Bash
input_match: "(git( +(-C +[^ \"]+|-c +[^ \"]+|--[a-z-]+(=[^ \"]+)?))* +(add|commit|push|rebase|reset|restore|clean|rm|mv|cherry-pick|revert)\\b|git( +(-C +[^ \"]+|-c +[^ \"]+|--[a-z-]+(=[^ \"]+)?))* +merge([^-]|$)|git( +(-C +[^ \"]+|-c +[^ \"]+|--[a-z-]+(=[^ \"]+)?))* +(switch|checkout) +[^ \"]|git( +(-C +[^ \"]+|-c +[^ \"]+|--[a-z-]+(=[^ \"]+)?))* +branch ([A-Za-z_]|-[dDmMcCf]|--(delete|move|copy|force))|git( +(-C +[^ \"]+|-c +[^ \"]+|--[a-z-]+(=[^ \"]+)?))* +stash( ?[^ a-z]|$| (push|pop|apply|drop|clear|save|store))|git( +(-C +[^ \"]+|-c +[^ \"]+|--[a-z-]+(=[^ \"]+)?))* +tag ([A-Za-z_]|[0-9]+\\.|-[adfsmu]|--(delete|force|annotate|sign))|gh pr (create|edit|merge|comment|review|close|reopen)|gh issue (create|edit|comment|close|reopen)|gh api .*(-X|--method)[ =]?(POST|PATCH|PUT|DELETE)|resolveReviewThread|addPullRequestReview)"
min: 0
max: 0
---
