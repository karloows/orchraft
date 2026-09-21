# AI Writing & Naming Policy

Never include secrets, tokens, API keys, or environment variable values in
branch names, commit messages, PR text, or user-facing summaries. Reference
variable names only. This does not apply to a non-secret external tracker
ticket key (e.g. `CPD-142`) used per `context/policies/branch-policy.md`'s
Optional Ticket Key section — that's an issue reference, not a credential.

## Workflow Requirements

- Before making code or documentation changes, check the current branch and working tree state.
- Follow any project-local agent instructions for workflow meanings, branch
  rules, commit rules, PR templates, and required checks.
- Never commit or push directly to the base branch, or to the repository's default branch when a configured `baseBranch` names another, unless the user explicitly asks for that exception.
- Before generating branch names, commit messages, or PR text, inspect the full
  intended change set with `git status`, `git diff`, staged diff, and untracked
  files that belong to the work.
- Generate branch names from the actual latest changes in the working
  directory and keep them compliant with
  `context/policies/branch-policy.md`.
- Prefer the GitHub MCP connector for PR creation or updates when it is
  available in the session. Use `gh` only after the MCP path has been tried
  and is unavailable or blocked.
- A plain `git push` can fail, or silently push under the wrong identity, if
  the local credential helper or `gh` has multiple GitHub accounts configured
  and the active one isn't the repo owner. A 403 on push is a credential
  problem, not a permissions grant to work around — verify the connected
  identity (`gh auth status`, or the GitHub MCP connector's `get_me`) and, if
  it lacks write access, fall back to the MCP connector's branch/push/PR
  tools (which authenticate independently of local git) instead of retrying
  the same push.

Recommended execution sequence:

1. Check branch and working tree state
2. Implement changes
3. Validate changes
4. Inspect the full intended change set
5. Create or confirm the correct branch before commit or push
6. Generate branch, commit, and PR text from the inspected changes
7. Commit with standards-compliant message
8. Push from a non-main branch

This document defines how AI agents must generate:

- PR titles
- PR descriptions

These rules override default LLM behavior.

---

## 1. Tone & Style

- Be concise and technical
- No marketing language
- No emojis
- Use active voice
- Avoid vague words: "improve", "stuff", "things"

---

## 2. PR Title Rules

Format:
    <type>: <short technical summary>

This format applies to PR titles only. PR titles intentionally omit scope,
with one exception: when the work is tracked in an external system (Jira,
Trello, Linear, or similar) and the user supplies the ticket key in the
request, or the target project's own local PR policy requires one, use it as
the scope instead — `<type>(TICKET-KEY): <short technical summary>` (e.g.
`feat(CPD-142): add offline cache for user profile`). Never invent, guess, or
derive a ticket key from the change itself. Commit messages must follow the
commit-specific prompt rules.

Allowed types:

- feat
- fix
- docs
- style
- refactor
- perf
- test
- build
- ci
- chore
- revert
- security
- deps

Examples:

- feat: add offline cache for user profile
- fix: prevent crash when token is null
- security: tighten token redaction
- deps: update lint dependencies

---

## 3. PR Description Rules

PR descriptions are required. Keep them branch-scoped and review-oriented.
They summarize the whole pull request, not just one commit.

If the target project provides a pull request template or has CI/review checks
that enforce PR body sections, headings, checklists, or layout, follow that
required format first. Fill every applicable required field with meaningful
content. Use the default sections below only when the project has no stricter
PR format.

Never hard-wrap a paragraph. Write each one as a single unbroken line and let
GitHub wrap it to the reader's viewport. This is the opposite of
`commit-policy.md`'s 72-character rule, and the difference is not a style
preference: GitHub renders pull request bodies, issue bodies, comments, and
release notes with line breaks enabled, so every newline inside a paragraph
becomes a literal `<br>`. A body wrapped for a terminal therefore renders with
a ragged right edge that looks like stray padding, and it never reflows on a
narrow screen. The same applies to anything else posted to GitHub — issue
bodies, review comments, and release notes — not just pull request
descriptions.

Line breaks that are genuinely intended still work normally: blank lines
between paragraphs, list items, headings, and fenced code blocks are
unaffected, since the rule covers wrapping inside a paragraph only.

Use these default sections in this order:

### Summary

Explain why the branch exists and what it accomplishes in one short paragraph.
Include the relevant context a reviewer needs before reading the diff.

### Changes

The important technical changes across the branch. Group related edits instead
of listing every file. Use bullets when there is more than one meaningful
change.

### Validation

Which checks ran, or why a check could not run. Include local validation and
relevant hook behavior when hooks changed files or blocked a commit.

### Risk

Call out reviewer-relevant risk, rollout concerns, migrations, compatibility
notes, or user-visible behavior changes. Write `None` only when there is
genuinely no notable risk.

### Notes

Optional. Use only for reviewer context that does not fit the first three
sections, such as migration notes, known limitations, screenshots, or follow-up
links. Omit this section when there is nothing useful to say.

Every non-optional section must contain specific content. Avoid placeholder
text, empty headings, and generic summaries such as "updated files" or "minor
changes."

Do not copy the commit body blindly. A commit body describes the staged diff;
a PR body describes the reviewable branch.

---

## 4. Skill Description Rules

Format for a skill's frontmatter `description`:

    Have the AI <verb phrase describing what it does>. Use when the user says <trigger word>, asks to <trigger phrase>, or wants <outcome>.

- First sentence: what the skill does, from the AI's perspective ("Have the
  AI ...").
- Second sentence: `Use when ...`, listing the words/phrases that should
  trigger it.
- Keep both sentences on one line in the frontmatter; no line breaks.

Example:

    Have the AI explain something grounded in real sources, not a confident guess. Use when the user says yap, asks "explain this", or wants a walkthrough of an error.

## 5. Things the AI must NEVER do

- Never invent features not mentioned
- Never add hype or praise
- Never apologize
- Never use "this PR does..."
- Never exceed 12 words in titles
