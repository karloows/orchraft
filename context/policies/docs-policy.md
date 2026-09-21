# Docs Policy

This policy applies to any AI agent drafting or updating a standalone
Markdown document — README sections, ROADMAP entries, design docs, feature
write-ups — as opposed to in-code comments or docstrings
(`context/policies/lore-policy.md`) or PR/commit text
(`context/policies/writing-guidelines.md`, `context/policies/commit-policy.md`).
User instructions and a target project's own documentation conventions take
priority.

## When To Write Or Update Something

- Write a new section, or a new file, when a real change (a shipped feature,
  a design decision, a policy) has nothing documenting it yet and someone
  other than the author needs to understand it without reading the diff.
- Update an existing doc when it no longer matches what the repo actually
  does — a stale install step, a missing entry in a list that grew, a
  described behavior that changed.
- Default to leaving a doc alone if it's still accurate. A missing doc is
  cheaper to notice and add than a wrong one is to catch.

## Grounding

Every claim in a drafted or updated doc must trace to something readable:
the diff, the surrounding code, commit history, or PR/issue text. This is
the same "no bluffing" rule the rest of this repo runs on, applied to prose
about the system instead of prose inside it.

- If a document needs to explain *why* something exists — intent, a
  tradeoff, a rejected alternative — and that reasoning isn't recoverable
  from any real source, say so and ask instead of writing a plausible
  narrative. A confident-sounding invented rationale is worse than an
  explicit gap, because a reader has no way to tell the two apart later.
- Cite the source when it isn't obvious from context (a PR number, a commit,
  a linked issue) so a later reader — human or agent — can verify the claim
  without re-deriving it.
- Never describe planned or aspirational behavior as already shipped, and
  never describe shipped behavior as merely planned; match the doc's tense
  to what's actually true right now.

## Shape

- Match the structure and heading style already used in the target file, or
  the closest comparable doc in the repo when creating one with no direct
  precedent. Don't impose a new structural convention on an existing doc
  just because it's not how the acting agent would have written it.
- Keep sections skimmable: a short paragraph or a tight list, not a wall of
  prose. Every sentence should carry information specific to this repo, not
  generic advice a reader could get from any project's docs.
- No filler sections, no placeholder text ("add details here," "coming
  soon") in place of real content — if content isn't available yet, omit the
  section rather than stub it.

## Tone

Default to the plain, technical tone `context/policies/writing-guidelines.md`
already defines for PR text — concise, no marketing language, active voice —
since that's this repo's working default for anything read by someone
deciding whether to trust or use the thing being described.

The orc voice from `context/personality.md` only applies where that file's
own "Where The Voice Applies" section says it does (for example, a README
introduction) — most standalone documentation content, including ROADMAP
entries and design docs, stays plain even when this skill's own success
message uses the voice.

## Examples

Grounded claim, with a source a reader can verify:

```markdown
orchraft installs as a Codex CLI plugin the same way it installs in Claude
Code (PR #33), with no skill content changes needed since `skills/` is the
default component-discovery directory both ecosystems already scan without
a manifest declaration.
```

Explicit gap instead of an invented rationale:

```markdown
The retry limit is 3. Why 3 specifically isn't stated in the code, its
history, or the linked issue — treat it as an open question if this needs
justifying later.
```

Placeholder filler to avoid:

```markdown
## Configuration

More details coming soon.
```
