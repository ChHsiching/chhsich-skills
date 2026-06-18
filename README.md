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

## Install — Z.ai ZCode (one command)

ZCode has no built-in third-party plugin installer (no `/plugin` command, no marketplace GUI — verified against ZCode 3.1.1). The bootstrap script mirrors ZCode's **own** plugin layout so it picks the plugin up at startup:

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/ChHsiching/chhsich-skills/main/install/zcode.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/ChHsiching/chhsich-skills/main/install/zcode.ps1 | iex
```

Restart ZCode. The four skills load reliably (linked into `~/.zcode/skills/`, which ZCode scans at startup). The `git-discipline` hook is registered as a plugin in ZCode's own layout — verify it blocks a bad commit after restart. See [`install/`](install/) for exactly what the script does.

### Dependencies (ECC + superpowers + mattpocock + karpathy)

chhsich-skills pulls in ECC, superpowers, mattpocock (`diagnosing-bugs` / `triage` / `tdd`), and karpathy. Install them into ZCode too — idempotent, skips anything already present:

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/ChHsiching/chhsich-skills/main/install/zcode-deps.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/ChHsiching/chhsich-skills/main/install/zcode-deps.ps1 | iex
```

Driven by `install/zcode-deps.json`; core logic in `install/zcode-deps.js` (cross-platform Node — Linux/macOS/Windows). See [`docs/superpowers/specs/2026-06-19-zcode-deps-installer-design.md`](docs/superpowers/specs/2026-06-19-zcode-deps-installer-design.md).

> ZCode can already parse this plugin format (`.claude-plugin/plugin.json`, `hooks/hooks.json`, `CLAUDE_PLUGIN_ROOT`) — it just lacks an installer. When ZCode adds one, the same `/plugin`-style steps as Claude Code will apply unchanged.

## Manual install (any client, no plugin system)

Clone and wire the hook by hand — see `skills/git-discipline/REFERENCE.md`.

> Requires the ECC, superpowers, and andrej-karpathy-skills plugins plus the mattpocock skills — these four are orchestration glue over that stack.

## Composition

`parallel-issue-execution` invokes `ecc-subagent-invocation` (how to spawn) and `bugfix-discipline` (how to fix). `git-discipline` auto-enforces commit/merge/branch rules via its PreToolUse hook (registered by the plugin). A goal prompt references whichever it needs via `Skill("…")`.

## Conventions

- One capability per skill (see Claude Code [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) best practices).
- SKILL.md ≤ 100 lines; detail in REFERENCE.md (progressive disclosure).
- Descriptions include "Use when..." triggers.
