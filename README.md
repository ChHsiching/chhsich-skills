# chhsich-skills

Personal Claude Code Agent Skills — reusable across projects and iterations.

## Skills

- **ecc-subagent-invocation** — spawn subagents correctly in this harness (Agent vs Task*, ToolSearch loading, verified `subagent_type`, self-contained prompts).
- **parallel-issue-execution** — orchestrate the ultracode execution phase: route Issues to GAN / bug-fix, parallel dispatch with file-domain isolation, six-element task prompts, cross-validation.
- **bugfix-discipline** — mandatory bug-fix protocol (diagnose + silent-failure-hunter + systematic-debugging escalation + quality-gate + impact analysis).

## Install (symlink into ~/.claude/skills)

These skills live here as the canonical source. To make Claude Code load them, symlink each skill directory into `~/.claude/skills/`:

```bash
cd ~/Git/Mine/chhsich-skills
for s in ecc-subagent-invocation parallel-issue-execution bugfix-discipline; do
  ln -sfn "$PWD/$s" ~/.claude/skills/"$s"
done
```

Restart Claude Code (or start a new session) so the skills are discovered.

Editing a skill here updates the live skill via the symlink — no copy step. Commit changes to git and push.

## Composition

`parallel-issue-execution` invokes `ecc-subagent-invocation` (how to spawn) and `bugfix-discipline` (how to fix). The three compose to cover the execution phase; a goal prompt just needs `Skill("parallel-issue-execution")`.

## Conventions

- One capability per skill (see Claude Code [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) best practices).
- SKILL.md ≤ 100 lines; detail in REFERENCE.md (progressive disclosure).
- Descriptions include "Use when..." triggers.
