---
type: tool_used
weight: 1
tool: Bash
input_match: "gh issue (create|edit|close|reopen|comment|delete|pin|unpin|transfer|lock|unlock)|gh api[^|]*(-X|--method) *(POST|PATCH|PUT|DELETE)[^|]*issues|gh api[^|]*issues[^|]*(-X|--method) *(POST|PATCH|PUT|DELETE)"
min: 0
max: 0
---
