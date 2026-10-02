# Pull Request Format

Use this as the fallback pull request shape when the target project has no
required PR template. A target project's template and review checks always
take priority.

## Title

```text
<type>: <short technical summary>
```

Use an external ticket key as the scope only when the user supplies it or a
project-local policy requires it:

```text
<type>(TICKET-KEY): <short technical summary>
```

## Body

### Summary

Why the branch exists and what it accomplishes.

### Changes

The important technical changes across the branch.

### Validation

Checks that ran, or why a check could not run.

### Risk

Reviewer-relevant risk, rollout concerns, migrations, or compatibility notes.
Write `None` when there is no notable risk.

### Notes

Optional reviewer context, known limitations, screenshots, or follow-up links.
Omit this section when it has nothing useful to add.
