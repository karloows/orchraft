# Tracking Card Format

Use this Markdown shape for a work card supplied by any external tracking
service:

```markdown
# Card title

- Tracker: <service name>
- Status: Backlog
- Labels: bug, authentication
- Assignees: @handle
- Due: YYYY-MM-DD
- Link: https://...

## Description

Why this work matters and what needs to change.

## Checklist

- [ ] First acceptance criterion
- [ ] Second acceptance criterion

## Notes

Optional implementation context, constraints, or related links.
```

- `# Card title` is required and should be concise and technical.
- All metadata lines are optional; omit unknown metadata instead of inventing
  it.
- Use `YYYY-MM-DD` for `Due`; use `None` when a requested due date is
  explicitly unset.
- Put the card's user-visible goal in `Description` and verifiable outcomes
  in `Checklist`.
- Keep unchecked checklist items as `- [ ]`; use `- [x]` only for work the
  source card already marks complete.
- Preserve the external tracking link when one is supplied. Never invent a
  link, tracker name, card ID, or ticket key.

## Optional Synchronization

- Treat a supplied card as task context, not approval to edit code, git, or an
  external tracking service.
- This format does not synchronize card status by itself. If the project has
  configured an MCP connector, local command, or other tracker integration and
  the user has enabled progress syncing, use that integration to update the
  card at each requested workflow step.
- Map workflow states to the tracker's existing statuses; never invent a
  status, label, field, or card ID.
- Confirm each external update before reporting it. If no configured
  integration is available, report the local progress without claiming the
  card changed.
- When converting a card into a branch, commit, PR, or issue, use its title,
  description, and checklist as source context; do not copy the whole card
  into commit or PR text unless requested.
