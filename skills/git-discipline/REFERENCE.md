# Git Discipline — Reference

## Wiring the hook

> If you installed the **chhsich-skills plugin** (`/plugin install chhsich-skills@chhsich-skills`), this is already wired automatically via `hooks/hooks.json` using `$CLAUDE_PLUGIN_ROOT` — skip this section. The manual wiring below is only for consuming the skill files directly (clone, no plugin install).

`scripts/git-guard.sh` is a Claude Code PreToolUse hook (matcher: `Bash`). When not using the plugin, reference it in `~/.claude/settings.json`:

```json
"hooks": {
  "PreToolUse": [
    { "matcher": "Bash",
      "hooks": [
        { "type": "command",
          "command": "bash /ABS/PATH/TO/chhsich-skills/skills/git-discipline/scripts/git-guard.sh" }
      ] }
  ]
}
```

Restart Claude Code after changing settings.json hooks. The hook reads the tool-input JSON on stdin and exits `2` to block (its stderr is shown to the model).

## Conventional commits

```
<type>(<scope>): <description>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci, build, style, revert.
Scope is optional but recommended for multi-module projects.

Breaking change: append `!` after type/scope, e.g. `feat(api)!: drop v1 endpoints`.

## Airtight commit-message validation (optional)

`git-guard.sh` inspects the `-m` argument only. If you commit via `-F <file>` or the editor, add a native git `commit-msg` hook:

```bash
mkdir -p ~/Git/Mine/chhsich-skills/git-discipline/scripts/native-hooks
# place a commit-msg script there, then:
git config --global core.hooksPath ~/Git/Mine/chhsich-skills/git-discipline/scripts/native-hooks
```

Trade-off: `core.hooksPath` is global and overrides per-repo hooks. Some rules (branch `-d`, merge `--no-ff`) have no native git hook and rely on the Claude PreToolUse hook.

## git flow quick model

- `main` — release-ready only; merge via `--no-ff` from develop or `hotfix/*`.
- `develop` — integration branch; `feature/*` and `fix/*` merge here.
- `feature/*` — off develop; one feature per branch; merge back to develop.
- `fix/*` — off develop (hotfixes off `main`).

## Why each rule

- **`--no-ff`**: preserves the feature-branch topology so history shows each unit of work as a merge commit.
- **No `-d` after merge**: the branch name is part of the audit trail.
- **Atomic commits**: bisect-able, revertable history.
- **Tests before merge**: `develop`/`main` stay green.
