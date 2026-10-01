# Sandbox Policy

Some hosts, notably Codex CLI's default `workspace-write` sandbox, keep `.git`
read-only and block network access. Read-only git (`status`, `diff`, `log`)
still works; branch, commit, merge, stash, push, and `gh` calls do not.

## Recognizing A Sandbox Block

- `Operation not permitted` or `Read-only file system` on `.git/index.lock`,
  `.git/HEAD`, or a ref.
- DNS, host-resolution, or connection errors on `git push`, `git fetch`, or
  `gh`.

Treat these as the sandbox, not a repository problem. Do not delete lock files,
rename branches, or change the plan to get around them.

Plugins cannot grant Git metadata access through their own config files. The
host sandbox remains authoritative, so orchraft must stop when its escalation
path is unavailable or declined.

## Codex Configuration

A local Codex profile such as this can cause the boundary:

```toml
default_permissions = "workspace-safe"

[permissions.workspace-safe]
extends = ":workspace"
```

The workspace remains writable, but Codex can still keep `.git` and `.codex`
read-only. That blocks branch creation and commits even when ordinary files
can be edited. Removing or changing the local profile can enable a host mode
that supports Git mutations, subject to the user's approval policy. Adding a
`.git` write entry to a `:workspace` profile is not a reliable override.

orchraft does not create, edit, or remove this Codex configuration. Users who
want the safe default can keep it; users who want `ship` to mutate Git need a
host-approved mode that explicitly permits those operations.

## What To Do

- Rerun that one command with escalation. In Codex, that is
  `sandbox_permissions: "require_escalated"` with a short `justification`
  naming the exact action; elsewhere, the host's normal permission prompt.
- Escalate per command using the narrowest permission that meets the need.
  For network-only commands, `network_access = true` in Codex's `config.toml`
  may be enough; `writable_roots` does not unlock `.git`. If a Git operation
  still needs metadata access after scoped escalation, request full access for
  that command only and justify the exact action.
- If escalation is declined or unavailable, stop. Report which command was
  blocked and give the exact command for the user to run.

## What Not To Do

- Do not substitute the GitHub contents, branch, or push API for a blocked local
  commit, merge, or branch step. That skips the hygiene `ship` and `land`
  define. The MCP fallback in `writing-guidelines.md` is for push credential
  failures only.
- A sandbox escalation is not orchraft approval. The user's current-turn
  go-ahead from `approval-policy.md` is still required first; the sandbox
  prompt is a second, separate gate.
