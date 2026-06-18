# Git Discipline — Reference

## Wiring the hook

`scripts/git-guard.js` is a cross-platform (Node) PreToolUse hook (matcher: `Bash`). It needs only Node — no bash, jq, grep, or sed — so it runs on Windows, macOS, and Linux in Claude Code and Z.ai ZCode alike.

### Via the plugin (recommended)

Install the **chhsich-skills plugin** in Claude Code and the hook wires itself: `hooks/hooks.json` runs `node "${CLAUDE_PLUGIN_ROOT}/skills/git-discipline/scripts/git-guard.js"`, and both Claude Code and ZCode substitute `${CLAUDE_PLUGIN_ROOT}` (and set it as an env var) when running plugin hooks. Nothing to add to `settings.json`. Skip to [Conventional commits](#conventional-commits).

### Manual (clone, no plugin)

Reference it in `~/.claude/settings.json` (Claude Code) or under `plugins` in `~/.zcode/cli/config.json` (ZCode):

```json
"hooks": {
  "PreToolUse": [
    { "matcher": "Bash",
      "hooks": [
        { "type": "command",
          "command": "node /ABS/PATH/TO/chhsich-skills/skills/git-discipline/scripts/git-guard.js" }
      ] }
  ]
}
```

Restart the client after editing hooks. The hook reads the tool-input JSON on stdin and exits `2` to block (its stderr is shown to the model).

## Conventional commits

```
<type>(<scope>): <description>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci, build, style, revert.
Scope is optional but recommended for multi-module projects.

Breaking change: append `!` after type/scope, e.g. `feat(api)!: drop v1 endpoints`.

## Airtight commit-message validation (optional)

`git-guard.js` inspects the `-m` argument only. If you commit via `-F <file>` or the editor, add a native git `commit-msg` hook:

```bash
mkdir -p /ABS/PATH/TO/chhsich-skills/skills/git-discipline/scripts/native-hooks
# place a commit-msg script there, then:
git config --global core.hooksPath /ABS/PATH/TO/chhsich-skills/skills/git-discipline/scripts/native-hooks
```

Trade-off: `core.hooksPath` is global and overrides per-repo hooks. Some rules (branch `-d`, merge `--no-ff`) have no native git hook and rely on the Claude/ZCode PreToolUse hook.

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
