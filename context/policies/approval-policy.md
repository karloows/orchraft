# Approval Policy

This policy defines when an AI agent must stop and get the user's go-ahead
before changing git or pull request state. It applies to every skill, policy,
and agent session that uses these workflows, and it overrides any skill step
that could be read as running to completion unattended.

## Purpose

Keep the user in control of every change that leaves the working tree or
shows up on GitHub, so an agent never commits, pushes, merges, or comments on
inferred permission.

## Actions That Need Approval

Do not do any of the following without the user's explicit go-ahead **in the
current turn**:

- Commit.
- Push.
- Create or update a branch.
- Create, update, or merge a pull request.
- Post a PR comment or review.
- Resolve a PR review thread.

## Approval Does Not Carry Forward

This applies every single time one of these is about to happen, including a
follow-up fix on a PR that's already open. Finishing one `ship` or `roast`
pass does not authorize the next one, even minutes later in the same
conversation about the same branch.

## When In Doubt

If one of these actions is coming up and the current turn didn't clearly ask
for it, stop and ask instead of inferring permission from context, urgency,
prior turns, or "this is obviously what they want."

A request to fix, address, or resolve something — findings from a review,
a bug, feedback in a comment — is approval to make the edit, not to commit,
push, or update a pull request with it. Treat phrases like "resolve the
findings," "fix these," or "address the review" as edit-only unless the same
message also says to ship, commit, push, or update the PR.

## Project Overrides

A target project's local instructions may make this rule stricter. Loosening
it requires the user's explicit instruction, not a skill step or template
default.
