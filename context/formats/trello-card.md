# Trello Card Format

Use this Markdown shape for a Trello card draft or a card supplied as agent
context:

```markdown
# Card title

- List: Backlog
- Labels: bug, authentication
- Members: @handle
- Due: YYYY-MM-DD
- Link: https://trello.com/c/...

## Description

Why this work matters and what needs to change.

## Checklist

- [ ] First acceptance criterion
- [ ] Second acceptance criterion

## Notes

Optional implementation context, constraints, or related links.
```

- `# Card title` is required and should be concise and technical.
- `List`, `Labels`, `Members`, `Due`, and `Link` are optional metadata lines.
- Omit unknown metadata instead of inventing it.
- Use `YYYY-MM-DD` for `Due`; use `None` when a requested due date is
  explicitly unset.
- Put the card's user-visible goal in `Description` and verifiable outcomes
  in `Checklist`.
- Keep unchecked checklist items as `- [ ]`; use `- [x]` only for work the
  source card already marks complete.
- Preserve the Trello URL when one is supplied. Never invent a card URL.

## Agent Notes

- Treat a supplied card as task context, not approval to edit code, git, or
  Trello.
- When drafting a card, include only fields supported by the request or the
  target project's local conventions.
- When converting a card into a branch, commit, PR, or issue, use the card
  title, description, and checklist as source context; do not copy the whole
  card into commit or PR text unless requested.
- Never derive a ticket key from a Trello URL or card title. Use one only when
  the user supplies it or a project-local rule defines it.
