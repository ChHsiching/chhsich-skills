# chhsich-skills

Personal Claude Code Agent Skills — reusable across projects and iterations. Distributed as a **Claude Code plugin** so the `git-discipline` PreToolUse hook installs automatically (no manual `settings.json` editing).

## Repo structure

A Claude Code plugin: the repo root is both a marketplace (`.claude-plugin/marketplace.json`) and the plugin itself (`.claude-plugin/plugin.json`, `source: "./"`). Skills live under `skills/`; `hooks/hooks.json` is auto-loaded by Claude Code and points at the git-guard script via `$CLAUDE_PLUGIN_ROOT`.

```
chhsich-skills/
├── .claude-plugin/
│   ├── marketplace.json      # makes this repo a plugin marketplace
│   └── plugin.json           # the plugin: declares ./skills/ (hooks auto-discovered)
├── hooks/
│   └── hooks.json            # PreToolUse Bash → git-guard.sh (via $CLAUDE_PLUGIN_ROOT)
├── skills/
│   ├── bugfix-discipline/SKILL.md
│   ├── ecc-subagent-invocation/{SKILL.md, REFERENCE.md}
│   ├── git-discipline/{SKILL.md, REFERENCE.md, scripts/git-guard.sh}
│   └── parallel-issue-execution/{SKILL.md, REFERENCE.md}
└── README.md
```

## Skills

- **ecc-subagent-invocation** — spawn subagents correctly in this harness (Agent vs Task*, ToolSearch loading, verified `subagent_type`, self-contained prompts).
- **parallel-issue-execution** — orchestrate the ultracode execution phase: route Issues to GAN / bug-fix, parallel dispatch with file-domain isolation, six-element task prompts, cross-validation.
- **bugfix-discipline** — mandatory bug-fix protocol (diagnosing-bugs + silent-failure-hunter + systematic-debugging escalation + quality-gate + impact analysis).
- **git-discipline** — strict git workflow: conventional commits, no Co-Authored-By, `--no-ff` merges, no branch deletion, no ignored files (auto-enforced by the plugin's PreToolUse hook); plus git-flow, atomic commits, tests-before-merge, triage-after-merge (guided).

## Install

A Claude Code plugin — installs identically in any Claude Code-compatible client (Claude Code, Z.ai ZCode, …). The `git-discipline` hook wires itself via `$CLAUDE_PLUGIN_ROOT`, which all these clients set on plugin load.

```
/plugin marketplace add ChHsiching/chhsich-skills
/plugin install chhsich-skills@chhsich-skills
```

Restart the client. The four skills are available and the PreToolUse hook is active. Update later via the `/plugin` menu.

### Where it lands per client

| Client | Plugins dir | Enabled-plugins file |
|---|---|---|
| Claude Code | `~/.claude/plugins/` | `~/.claude/settings.json` |
| Z.ai ZCode | `~/.zcode/cli/plugins/` | `~/.zcode/cli/config.json` |

ZCode is a Claude Code-compatible client — same plugin/marketplace/hook format, same `$CLAUDE_PLUGIN_ROOT` (verified against its bundled `superpowers` plugin). The two commands above are identical; just run them inside ZCode instead of Claude Code.

> Requires the ECC, superpowers, and andrej-karpathy-skills plugins plus the mattpocock skills — these four are orchestration glue over that stack.

## Manual hook wiring (only if NOT using the plugin)

If you consume the skill files directly (clone, no plugin), wire the hook by hand in `~/.claude/settings.json` — see `skills/git-discipline/REFERENCE.md`. The plugin path above is strongly preferred.

## Composition

`parallel-issue-execution` invokes `ecc-subagent-invocation` (how to spawn) and `bugfix-discipline` (how to fix). `git-discipline` auto-enforces commit/merge/branch rules via its PreToolUse hook (registered by the plugin). A goal prompt references whichever it needs via `Skill("…")`.

## Conventions

- One capability per skill (see Claude Code [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) best practices).
- SKILL.md ≤ 100 lines; detail in REFERENCE.md (progressive disclosure).
- Descriptions include "Use when..." triggers.
