# chhsich-skills

Personal Claude Code Agent Skills — reusable across projects and iterations.

## Repo structure

Each skill is its own top-level directory (the official model: `SKILL.md` + optional `REFERENCE.md` / `scripts/` / `examples.md` inside the skill dir). A skill that ships a hook bundles the hook script in its own `scripts/`. The repo stays flat so each skill symlinks 1:1 into `~/.claude/skills/`.

```
chhsich-skills/
├── README.md
├── ecc-subagent-invocation/{SKILL.md, REFERENCE.md}
├── parallel-issue-execution/{SKILL.md, REFERENCE.md}
├── bugfix-discipline/SKILL.md
└── git-discipline/{SKILL.md, REFERENCE.md, scripts/git-guard.sh}
```

## Skills

- **ecc-subagent-invocation** — spawn subagents correctly in this harness (Agent vs Task*, ToolSearch loading, verified `subagent_type`, self-contained prompts).
- **parallel-issue-execution** — orchestrate the ultracode execution phase: route Issues to GAN / bug-fix, parallel dispatch with file-domain isolation, six-element task prompts, cross-validation.
- **bugfix-discipline** — mandatory bug-fix protocol (diagnosing-bugs + silent-failure-hunter + systematic-debugging escalation + quality-gate + impact analysis).
- **git-discipline** — strict git workflow: conventional commits, no Co-Authored-By, `--no-ff` merges, no branch deletion, no ignored files (auto-enforced by `scripts/git-guard.sh`); plus git-flow, atomic commits, tests-before-merge, triage-after-merge (guided).

## Install

```bash
npx skills@latest add ChHsiching/chhsich-skills
```

Symlinks all four skills into your agent directory. Options: `--copy` (copy instead of symlink), `-s <name>` (install one skill), `--list` (preview without installing). Re-run to update.

Then wire the `git-discipline` PreToolUse hook into `~/.claude/settings.json` (see `git-discipline/REFERENCE.md`). `npx skills add` installs the skill but does **not** auto-register its hook — without this step the commit/merge discipline won't actually fire. Restart Claude Code.

> Designed for the ECC, superpowers, and andrej-karpathy-skills plugins plus the mattpocock skills — these four are orchestration glue over that stack.

## Composition

`parallel-issue-execution` invokes `ecc-subagent-invocation` (how to spawn) and `bugfix-discipline` (how to fix). `git-discipline` auto-enforces commit/merge/branch rules via its PreToolUse hook. A goal prompt references whichever it needs via `Skill("…")`.

## Conventions

- One capability per skill (see Claude Code [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) best practices).
- SKILL.md ≤ 100 lines; detail in REFERENCE.md (progressive disclosure).
- Descriptions include "Use when..." triggers.
