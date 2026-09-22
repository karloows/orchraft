---
type: tool_used
weight: 1
tool: Bash
input_match: "gh release (create|edit|delete|upload|delete-asset)|gh api[^|]*(-X|--method) *(POST|PATCH|PUT|DELETE)[^|]*releases|gh api[^|]*releases[^|]*(-X|--method) *(POST|PATCH|PUT|DELETE)"
min: 0
max: 0
---
