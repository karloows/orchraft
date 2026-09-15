# Commit Policy

This policy applies to any AI coding assistant generating commit messages.
User instructions, project-local rules, and the actual staged diff take
priority.

This policy applies to every commit. When the user says `ship`, it activates
the commit workflow for the current staged diff, but the title and body rules
remain mandatory for all commits.

## Format

Use:

`<type>(<scope>): <summary>`

Follow the title with a blank line and a required structured body.

Use these sections in this order as markdown headings:

`## Context`

`## Changes`

`## Validation`

## Why This Format Exists

Projects use commits as a searchable history of what changed, why it
changed, and how it was verified. A short subject line is enough for the index,
but reviewers still need a body that ties the diff to the repo areas it touched
and the checks that actually ran.

The body is not optional because changes often cross boundaries, touch shared
contracts, or update workflow docs that need a plain-language rationale. That
is especially important in multi-package or multi-service projects.

## Title Rules

- Use the conventional type that best matches the staged changes.
- Use the narrowest scope that fits the dominant diff.
- Keep the summary technical, specific, and written in imperative mood.
- Do not use vague summaries such as `update docs` or `fix stuff`.
- Do not treat the body as optional, even for small diffs.
- Keep the subject concise enough to stay readable in release notes and merge
  history.

## Body Rules

- The body is required for every commit.
- Include all three required sections as markdown headings:
  `## Context`, `## Changes`, and `## Validation`.
- Add non-empty technical content under each section.
- Describe the staged changes only.
- Keep the language technical and explicit enough that a reviewer can
  understand the reason for the commit, the actual diff scope, and how it was
  checked without reading a vague one-line note.
- Aim for moderate detail by default: enough context to be useful in review,
  but not so much that the body becomes a changelog.
- Do not invent behavior, files, or follow-up work that is not in the diff.
- Prefer complete sentences over fragments when the change has workflow or
  architectural consequences.
- Do not use graphs or other visual artifacts in commit bodies unless the user
  explicitly asks for them and the medium supports them.

## How To Write The Sections

- `## Context` should explain what problem, constraint, or repo mismatch caused
  the change.
- `## Changes` should explain the concrete edits made in the staged diff.
- `## Validation` should name the checks that ran or explain why a check could
  not run.

That structure keeps commit bodies review-oriented without turning them into a
log of every file touched. It also makes it easier to see which commits are
documentation-only, tooling-only, or behavior-changing without opening the
entire patch.

## Examples

```text
docs(agents): align monorepo policy baseline

## Context

The repository workflow docs still described the agent rules in a way that did
not reflect the current monorepo structure or branch workflow.

## Changes

Update the policy set to cover branch naming, commit formatting, validation,
and handoff behavior in a way that matches the repository workflow.

## Validation

Review the updated docs for consistency with the repository layout and current
workflow.
```

```text
fix(app): prevent crash in cache hydration

## Context

App startup can fail when cached state is missing the expected hydration shape.

## Changes

Add a guard in the hydration path and keep the fix limited to the code that
reads the cache.

## Validation

Run the test and lint commands that cover the touched area, then review
the resulting behavior locally.
```
