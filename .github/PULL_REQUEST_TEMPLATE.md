## Summary

<!-- What changed, and why — not just what the diff shows. -->

## Which skill(s) or policy(ies) does this touch?

<!-- e.g. .agents/skills/ship/SKILL.md, context/policies/commit-policy.md -->

## Checklist

- [ ] Canonical file edited under `.agents/skills/` (not the `.claude/skills/` symlink)
- [ ] `AGENTS.md` / `README.md` updated if a skill or policy was added, renamed, or removed
- [ ] No project-specific build/test/deploy assumptions baked into skill or policy text
- [ ] Mutating git/GitHub actions in any new/changed skill step stay gated behind `context/policies/approval-policy.md`
- [ ] Relevant eval case added or updated under `evals/`, and run locally:
      `claude plugin eval . --case <name> --runs 1 --no-publish`

## Related issue

<!-- Fixes #123, or "None" -->
