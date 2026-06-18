# chhsich-skills

Personal Claude Code Agent Skills — reusable across projects and iterations. Distributed as a **Claude Code plugin**; the `git-discipline` PreToolUse hook is a cross-platform Node script, so it runs on Windows/macOS/Linux with no extra dependencies (no bash, jq, grep, sed).

## Repo structure

A Claude Code plugin: the repo root is both a marketplace (`.claude-plugin/marketplace.json`) and the plugin itself (`.claude-plugin/plugin.json`, `source: "./"`). Skills live under `skills/`; `hooks/hooks.json` is auto-loaded by Claude Code / ZCode and points at the Node hook via `${CLAUDE_PLUGIN_ROOT}`.

```
chhsich-skills/
├── .claude-plugin/
│   ├── marketplace.json      # makes this repo a plugin marketplace
│   └── plugin.json           # the plugin: declares ./skills/ (hooks auto-discovered)
├── hooks/
│   └── hooks.json            # PreToolUse Bash → git-guard.js (via ${CLAUDE_PLUGIN_ROOT})
├── skills/
│   ├── bugfix-discipline/SKILL.md
│   ├── ecc-subagent-invocation/{SKILL.md, REFERENCE.md}
│   ├── git-discipline/{SKILL.md, REFERENCE.md, scripts/git-guard.js}
│   └── parallel-issue-execution/{SKILL.md, REFERENCE.md}
└── README.md
```

## Skills

- **ecc-subagent-invocation** — spawn subagents correctly in this harness (Agent vs Task*, ToolSearch loading, verified `subagent_type`, self-contained prompts).
- **parallel-issue-execution** — orchestrate the ultracode execution phase: route Issues to GAN / bug-fix, parallel dispatch with file-domain isolation, six-element task prompts, cross-validation.
- **bugfix-discipline** — mandatory bug-fix protocol (diagnosing-bugs + silent-failure-hunter + systematic-debugging escalation + quality-gate + impact analysis).
- **git-discipline** — strict git workflow: conventional commits, no Co-Authored-By, `--no-ff` merges, no branch deletion, no ignored files (auto-enforced by the plugin's PreToolUse hook); plus git-flow, atomic commits, tests-before-merge, triage-after-merge (guided).

## Install — Claude Code (Windows / macOS / Linux)

```
/plugin marketplace add ChHsiching/chhsich-skills
/plugin install chhsich-skills@chhsich-skills
```

Restart Claude Code. All four skills are available and the `git-discipline` hook is active on every platform (the hook is plain Node). Update later via the `/plugin` menu.

## Install — Z.ai ZCode

**ZCode currently has no entry point for third-party plugins** — no `/plugin` command, no marketplace GUI, no install API (verified against ZCode 3.1.1's bundled code). ZCode *can* read this plugin format (it parses `.claude-plugin/plugin.json`, runs `hooks/hooks.json`, and sets `CLAUDE_PLUGIN_ROOT`), but offers no way to land a GitHub plugin on disk. Until ZCode adds an installer:

- The skills are usable by placing them under `~/.zcode/skills/` (ZCode scans it at startup).
- The `git-discipline` PreToolUse hook **cannot** be auto-loaded this way — it only loads from an installed plugin, which ZCode can't yet do. You can still wire it manually in `~/.zcode/cli/config.json` (see `skills/git-discipline/REFERENCE.md`).

When a future ZCode release adds a plugin/marketplace installer, the same steps as Claude Code will apply unchanged.

## Manual install (any client, no plugin system)

Clone and wire the hook by hand — see `skills/git-discipline/REFERENCE.md`.

> Requires the ECC, superpowers, and andrej-karpathy-skills plugins plus the mattpocock skills — these four are orchestration glue over that stack.

## Composition

`parallel-issue-execution` invokes `ecc-subagent-invocation` (how to spawn) and `bugfix-discipline` (how to fix). `git-discipline` auto-enforces commit/merge/branch rules via its PreToolUse hook (registered by the plugin). A goal prompt references whichever it needs via `Skill("…")`.

## Conventions

- One capability per skill (see Claude Code [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) best practices).
- SKILL.md ≤ 100 lines; detail in REFERENCE.md (progressive disclosure).
- Descriptions include "Use when..." triggers.
