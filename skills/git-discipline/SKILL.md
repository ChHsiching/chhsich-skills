---
name: git-discipline
description: Enforce and guide a strict git workflow — conventional commits, no Co-Authored-By, --no-ff merges, no branch deletion, no ignored files, plus git-flow branching, atomic commits, tests-before-merge, and triage-after-merge. Use when committing, merging, branching, or finishing a feature or fix.
---

# Git Discipline

Two layers: a PreToolUse hook (`scripts/git-guard.js`, auto-wired by the plugin or manually in settings.json) auto-blocks the machine-checkable rules; this skill guides the judgment calls.

## Auto-enforced by git-guard.js (hook — blocks, not advisory)

- **No `Co-Authored-By`** in commit messages.
- **Conventional commits**: `type(scope?): description` — feat / fix / refactor / docs / test / chore / perf / ci / build / style / revert.
- **Merge with `--no-ff`** (preserve branch topology). Use `--ff-only` only when you explicitly want a fast-forward.
- **No branch deletion**: `git branch -d/-D/--delete` is blocked.
- **No force-adding ignored files**: `git add -f/--force` is blocked.

The conventional-commits check inspects the `-m` message. For commits via `-F`/editor, see [REFERENCE.md](REFERENCE.md) for a native `commit-msg` hook.

## Guided here (judgment — read at decision time)

- **git flow**: `main` (release) + `develop` (integration) + `feature/*` / `fix/*`. Branch off develop, merge back to develop (hotfixes off main).
- **Atomic commits**: one logical change per commit. If a commit does two unrelated things, split it.
- **Tests must pass before merge**: run the branch's verify_command (unit + integration); do not merge red.
- **After merge**: invoke `Skill("triage")` to update Issue status/tags and document any bug + fix into the Issue.

## Don't

- Don't commit files matched by `.gitignore` (git refuses by default; the hook blocks `-f`).
- Don't delete the merged branch (topology must be preserved via `--no-ff`).
- Don't merge a feature branch with only a single commit unless it's a tiny atomic change.

See [REFERENCE.md](REFERENCE.md) for hook wiring, conventional-commits detail, and an optional airtight `commit-msg` setup.
