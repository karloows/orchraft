---
name: shaman
description: Have the AI run a read-only orchraft setup preflight. Use when the user says shaman, asks whether orchraft is ready, or wants a preflight before another workflow.
---

# Shaman Workflow

Use this skill before `ship`, `roast`, or `land` when setup is uncertain. It
reads the signs of the current repository; it never repairs anything.

## At A Glance

1. Resolve the current repository root and the orchraft plugin root.
2. Run the checks below without changing files, git state, GitHub, or Trello.
3. Report each check as `PASS`, `WARN`, or `FAIL`, then give the smallest next
   action and an explicit `READY` or `NOT READY` result.

## Checks

### Repository and skill loading

- Confirm `git rev-parse --show-toplevel` succeeds and report the repository
  root and current branch.
- Confirm the loaded orchraft package contains `skills/` and the skill files
  named by the requested workflow. If this skill is running, its own loading
  is a pass; inspect the package for the other requested skills rather than
  claiming every skill is available.
- Confirm the repository has an `origin` remote when a GitHub workflow is
  requested. Do not fetch, push, or alter remotes.

### Policy fallback

- For `approval-policy.md`, `config-policy.md`, and
  `verification-policy.md`, report whether the target repository provides a
  local copy or orchraft will use the bundled fallback.
- If a local policy exists, read it as the target repository's authority. A
  missing local policy is a warning only; fallback is supported.

### GitHub access

- If `gh` exists, run `gh auth status` and report its result without exposing
  tokens. A missing or unauthenticated `gh` is a warning when the configured
  GitHub connector can provide read access, otherwise a failure for workflows
  that need GitHub state.
- Confirm the origin URL is a GitHub repository when GitHub work is requested.
  Do not treat a successful local git command as proof of GitHub
  authentication.

### Required tools

- `git` is required for every workflow.
- `jq` is required for the bundled hooks; missing `jq` is a warning that
  ambient nudges will be silent.
- `gh` is required only when no authenticated GitHub connector is available.
- Report missing optional tools plainly instead of inventing a workaround.

### Config parsing

- Check `.orchraft.jsonc` first, then `.orchraft.json`, and ignore both when
  neither exists because config is optional.
- Parse the selected file as JSON. For `.jsonc`, use the same quote-aware
  comment stripping convention as `hooks/watchtower-nudge.sh`; never strip
  `//` inside a quoted URL.
- A malformed file is a `FAIL` that names the file and parse error, then
  explain that workflows will continue with documented defaults. Do not edit
  or rewrite the file.
- For a valid file, check only the documented types that affect the requested
  workflow. Unknown keys are not failures.

### Hook support

- If `hooks/hooks.json` is present, validate it as JSON, confirm every command
  it references exists, and confirm referenced scripts are executable.
- Confirm `jq` is available for the bundled hook scripts.
- Report unsupported host hook behavior as a warning with the host-specific
  limitation. Never install, enable, or modify a hook.

## Output

Use this compact format:

```text
Repository: <root> (<branch>)
<status>  Skills: <result>
<status>  Policies: <local/fallback result>
<status>  GitHub: <authenticated / connector / unavailable>
<status>  Tools: <result>
<status>  Config: <absent / valid path>
<status>  Hooks: <supported / not installed>

Next action: <smallest action, or none>
Result: READY | NOT READY
```

Use `FAIL` for a broken prerequisite or malformed config; any `FAIL` in a
requested workflow means `NOT READY`. Use `WARN` for a supported fallback or
unavailable optional integration; a warning permits `READY` only when the
requested outcome still works through that fallback or the warning concerns
an unavailable optional integration. Use `PASS` only for a check actually
performed in this turn. Never claim a check passed from memory.

## Guardrails

- Read-only: never create or update a branch, commit, push, fetch, open or
  update a PR, change an issue or release, mutate Trello, or edit files.
- Do not run commands that write caches, generated files, credentials, or
  dependency locks.
- Do not print secrets, tokens, full credential paths, or config values that
  may contain secrets.
- Stop after the report. The shaman may recommend `warplan`, `forgehand`,
  `ship`, `roast`, or `land`, but it never invokes the next workflow.
