# Commit Policy

This policy applies to any AI coding assistant generating commit messages.
User instructions, project-local rules, and the actual staged diff take
priority.

This policy applies to every commit. When the user says `ship`, it activates
the commit workflow for the current staged diff, but the title and body rules
remain mandatory for all commits.

## Format

Follows [Conventional Commits](https://www.conventionalcommits.org/) v1.0.0:

`<type>(<scope>): <summary>`

- Title: type, optional scope in parentheses, colon, space, short summary.
  Append `!` before the colon for a breaking change (e.g. `feat(api)!: ...`).
- Body: optional, one blank line after the title. The spec defines it as
  free-form text — "any number of newline separated paragraphs" — so plain
  prose paragraphs are the default; there is no required structure or line
  length. A bullet list is acceptable within that free-form body when a
  change has several distinct, list-worthy parts (see Examples), but is not
  the default shape.
- Footers: optional, one blank line after the body. Each footer is a
  `Token: value` (or `Token #value`) pair on its own line, e.g.
  `Fixes #123`, `Reviewed-by: name`. A breaking change is called out with a
  `BREAKING CHANGE: <description>` footer (the only token allowed to contain
  a space); when present, the title should already carry `!`.

## Why This Format Exists

Projects use commits as a searchable history of what changed, why it
changed, and how it was verified. A short subject line is enough for the index;
the body exists only for changes where the diff isn't self-explanatory.

## Title Rules

- Use the conventional type that best matches the staged changes.
- Use the narrowest scope that fits the dominant diff. When the work is
  tracked in an external system (Jira, Trello, Linear, or similar), the
  ticket key may be used as the scope instead — e.g. `fix(CPD-142): ...` —
  but only when the user supplies that key in the request or the target
  project's own local commit policy names one. Never invent, guess, or
  derive a ticket key from the diff.
- Keep the summary technical, specific, and written in imperative mood.
- Do not use vague summaries such as `update docs` or `fix stuff`.
- Keep the subject concise enough to stay readable in release notes and merge
  history.

## Body Rules

Conventional Commits does not require a body. Use a single rule: include a
body only when the title alone would leave a reviewer guessing why the
change exists. Touching multiple files/areas, changing behavior, or fixing a
non-obvious bug are common reasons a title falls short, not separate
requirements — if the title already fully explains a change like that, skip
the body.

- Skip the body when the title fully explains the change (e.g.
  `docs(agents): fix typo in branch-policy example`), even if the diff spans
  more than one file.
- Add a body when the title doesn't fully explain the change — for example
  when it touches multiple files/areas, changes behavior, or fixes a
  non-obvious bug in a way the title can't summarize on its own.
- When present, write free-form prose (no headings) covering why the change
  was needed and what changed; mention how it was validated only if that
  isn't obvious from the change itself.
- Wrap lines at roughly 72 characters (a git convention, not part of the
  Conventional Commits spec, but kept for readable `git log` output).
- Describe the staged changes only; do not invent behavior, files, or
  follow-up work that is not in the diff.
- Do not use graphs or other visual artifacts in commit bodies unless the user
  explicitly asks for them and the medium supports them.

## Examples

Title-only, small self-explanatory change:

```text
docs(agents): fix typo in branch-policy example
```

With a body, because the fix isn't obvious from the title alone:

```text
fix(app): prevent crash in cache hydration

App startup could fail when cached state was missing the expected hydration
shape. Add a guard in the hydration path, scoped to the code that reads the
cache. Verified by running the hydration test suite locally.
```

With a body, because the change spans multiple files/areas:

```text
docs(agents): align monorepo policy baseline

The repository workflow docs described the agent rules in a way that no
longer matched the monorepo structure or branch workflow. Update the policy
set to cover branch naming, commit formatting, validation, and handoff
behavior consistent with the current layout.
```

With a bulleted body, because the change has several distinct, list-worthy
parts:

```text
refactor(auth): consolidate token refresh handling

Token refresh logic was duplicated across three call sites and drifted out
of sync over time.

- Move refresh logic into a single `refreshToken` helper
- Update the API client and background sync job to call the helper
- Remove the now-dead per-call-site refresh code
```

With a breaking-change footer:

```text
feat(api)!: require API key on all requests

BREAKING CHANGE: requests without an `x-api-key` header now return 401.
Update client integrations to include the header before upgrading.
```
