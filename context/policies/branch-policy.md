# Branch Name Generator Specification

This document defines how AI agents must generate **branch names**.

## 1. Role

You are generating a **branch name** based on the type of change and a short technical description.

When a user says `"ship"`, this policy still governs how the branch name is generated. The shortcut authorizes the branch step, but it does not change the required branch format or allow branch names to be inferred from assumptions instead of the real diff.

Input may include:

- Task description
- PR purpose
- Commit summary

Your output must be **one branch name** following the rules below.

## 2. Output Format

The branch name must follow this structure:

    <type>/<short-kebab-description>

Where:

- `<type>` is one of the conventional commit types (see Section 3)
- `<short-kebab-description>` is a maximum of **3 words**, lowercase, hyphen-separated, summarizing the change

### Examples

    feat/offline-cache
    fix/null-token-crash
    docs/api-endpoints
    style/button-spacing
    refactor/auth-service
    perf/profile-load
    test/login-flow
    build/docker-image
    ci/release-checks
    chore/repo-config
    revert/cache-change
    security/token-redaction
    deps/eslint-update

## 3. Type Mapping (Conventional Commit Semantics)

The AI must pick the **most accurate type** based on the change description.

| Type     | Use When                                  |
| -------- | ----------------------------------------- |
| feat     | New feature or capability                 |
| fix      | Bug fix                                   |
| docs     | Documentation only                        |
| style    | Formatting or style-only code changes     |
| refactor | Code change without behavior change       |
| perf     | Performance improvement                   |
| test     | Adding or modifying tests                 |
| build    | Build system, packaging, or dependencies  |
| ci       | CI/CD changes                             |
| chore    | Repository maintenance or tooling         |
| revert   | Reverting an earlier change               |
| security | Security hardening or vulnerability fixes |
| deps     | Dependency-only updates                   |

## 4. Branch Description Rules

1. After the `/`, use **max 3 words**, all lowercase, hyphen-separated.
2. Use only **letters, numbers, and hyphens**. No spaces, underscores, or special characters.
3. Avoid vague words like: `stuff`, `things`, `update`, `misc`.
4. Be concise but descriptive.
5. Do not include the type in the short description (it’s already the prefix).
6. Optionally use one of the 3 allowed words for extra context if needed (e.g., `feat/user-auth-fix` uses `user`, `auth`, and `fix`).

### Examples

    feat/offline-cache
    fix/null-token-crash
    docs/api-endpoints
    style/button-spacing
    refactor/auth-service
    perf/profile-load
    test/login-flow
    build/docker-image
    ci/release-checks
    chore/repo-config
    revert/cache-change
    security/token-redaction
    deps/eslint-update

## 5. What the AI Must NEVER Do

- Never invent change types
- Never exceed 3 words after `/`
- Never use emojis or symbols
- Never include “branch-for” or “this-branch” in the name
- Never output multiple branch names

## 6. Examples

**Feature**

    feat/offline-cache
    feat/user-profile

**Fix**

    fix/null-token-crash
    fix/login-error

**Refactor**

    refactor/auth-service
    refactor/cache-handler

**Perf**

    perf/profile-load
    perf/image-render

**Docs**

    docs/api-endpoints
    docs/setup-guide

**Style**

    style/button-spacing
    style/format-imports

**Test**

    test/login-flow
    test/cart-validation

**Build**

    build/docker-image
    build/package-config

**CI**

    ci/release-checks
    ci/test-matrix

**Chore**

    chore/ci-config
    chore/repo-cleanup

**Revert**

    revert/cache-change
    revert/auth-refactor

**Security**

    security/token-redaction
    security/header-policy

**Deps**

    deps/eslint-update
    deps/flutter-packages

## 7. Summary / Conventions

This specification ensures that all branch names in the repository:

- Follow **conventional commit semantics** (feat, fix, docs, style, refactor,
  perf, test, build, ci, chore, revert, security, deps)
- Use **short, clear, and hyphen-separated descriptions** (max 3 words after the `/`)
- Are **machine- and human-readable**
- Maintain **consistent repo-wide branch naming conventions**

Following this guide helps the AI agent generate **predictable, structured, and standardized branch names** across all features, fixes, and changes.

## 8. Local Enforcement

If local hooks reject the branch name, rename the branch to match this policy
before committing.
