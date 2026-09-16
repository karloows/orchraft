# Lore Policy

Lore is this repo's word for in-code comments and docstrings — the narrative
context left behind in the source itself, as opposed to commit or PR text.

This policy applies to any AI coding assistant writing comments or docstrings
in any language or framework. User instructions and project-local style
guides (linter configs, `.editorconfig`, existing doc-comment conventions in
the touched file) take priority.

## When To Write Something

- **Docstring**: add one on a public function, method, class, or module when
  its name and signature don't already say what a caller needs to know.
  Trivial one-liners (a getter, a two-line pure function) don't need one.
- **Inline comment**: add one only for the non-obvious *why* — a workaround,
  a hidden constraint, a non-obvious invariant, a spec/ticket-driven edge
  case. Never comment the *what* when the code already reads clearly; delete
  a comment you can't distinguish from the code below it.
- Default to none. A missing comment is cheaper to add later than a stale one
  is to notice and remove.

## Docstring Shape

Same shape regardless of language — adapt syntax to the local doc-comment
convention (JSDoc, Google-style Python, Rustdoc, Javadoc, godoc, etc.):

1. One-line summary, imperative or descriptive, no restating the function
   name.
2. Blank line, then a short elaboration paragraph — only if the summary
   line doesn't already cover it.
3. Param/return/throws tags — only for params whose meaning, unit, or
   constraint isn't obvious from their name and type; skip tags that would
   just repeat the type signature.

Stop at the first line that's already true. A function whose name and types
are self-explanatory gets a summary line and nothing else.

## Rules

- Match the doc-comment syntax the language/tool ecosystem already expects
  (`/** */` for JS/TS, `"""..."""` for Python, `///` for Rust, `// Name ...`
  for Go) — never invent a custom format.
- Write in the third person for docstrings ("Returns the parsed config"),
  not first person or imperative-to-the-reader.
- No restating types, parameter names, or file paths the signature already
  shows.
- No commented-out code, TODO-as-changelog, or attribution to a task/ticket —
  that belongs in the commit or PR, not the source.
- No decorative banners, ASCII dividers, or emoji in comments.
- Keep it verbose enough to answer "what does this return and when does it
  throw," not verbose enough to narrate the implementation line by line.

## Examples

TypeScript (JSDoc), tag skipped because the param is self-explanatory:

```ts
/** Parses a raw cookie header into a key/value map. */
function parseCookies(header: string): Record<string, string> { ... }
```

TypeScript (JSDoc), tag kept because the constraint isn't obvious from the
signature:

```ts
/**
 * Retries `fn` with exponential backoff.
 *
 * @param maxAttempts Total attempts including the first call; must be >= 1.
 */
function retry<T>(fn: () => Promise<T>, maxAttempts: number): Promise<T> { ... }
```

Python (Google style):

```python
def parse_cookies(header: str) -> dict[str, str]:
    """Parses a raw cookie header into a key/value map."""
```

```python
def retry(fn: Callable[[], T], max_attempts: int) -> T:
    """Retries fn with exponential backoff.

    Args:
        max_attempts: Total attempts including the first call; must be >= 1.
    """
```

Go:

```go
// ParseCookies parses a raw cookie header into a key/value map.
func ParseCookies(header string) map[string]string { ... }
```

Inline comment for a non-obvious *why*, not a *what*:

```go
// Retry once on ECONNRESET: the upstream LB recycles idle connections
// after 60s and the client doesn't see it until the next write.
if isConnReset(err) && attempt == 0 {
    return retry()
}
```
