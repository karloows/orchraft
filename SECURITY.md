# Security Policy

## Supported Versions

orchraft is pre-1.0 (`0.x`). Security fixes land on the latest published
release; older `0.x` releases are not separately patched.

| Version | Supported |
| ------- | --------- |
| 0.x (latest) | ✅ |
| < latest 0.x | ❌ |

## Reporting a Vulnerability

Please report security vulnerabilities privately through GitHub's
[private vulnerability reporting](https://github.com/karloows/orchraft/security/advisories/new)
flow (Security tab → "Report a vulnerability") rather than opening a public
issue.

Include:

- A description of the vulnerability and its potential impact.
- Steps to reproduce it, including which skill, policy, or hook is
  involved.
- Any relevant logs, transcripts, or configuration (with secrets redacted).

You should expect an initial response within a few days. This is a
solo-maintainer project, so please be patient with turnaround time on a fix.

## Scope

orchraft is a set of Claude Code skills, policies, and shell hooks that
propose git/GitHub actions for the user to approve — it does not execute
mutations without a current-turn go-ahead (`context/policies/approval-policy.md`).
Security-relevant reports include anything that could:

- Cause a skill or hook to perform a git/GitHub mutation without the
  required approval.
- Leak secrets, tokens, or credentials into branch names, commit messages,
  PR text, or logs.
- Execute unintended shell commands via `hooks/watchtower-nudge.sh` or an
  eval case.

General bug reports that don't involve a security impact should go through
the normal [issue tracker](https://github.com/karloows/orchraft/issues)
instead.
