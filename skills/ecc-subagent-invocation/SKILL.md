---
name: ecc-subagent-invocation
description: Spawn Claude Code subagents correctly in this harness — load the Agent tool via ToolSearch, verify ECC subagent_type names against the ecc-guide registry, write self-contained prompts, and distinguish Agent (subagent dispatch) from the Task* family (todo tracking). Use when you need to dispatch or spawn a subagent, reference Task/Agent in a workflow, or hit errors spawning agents.
---

# ECC Subagent Invocation

Spawn subagents reliably in this Claude Code + ECC setup. The harness defers and renames tools, so naive spawning fails — follow this exactly.

## Two tool families — do not confuse

- **Agent** = subagent dispatch. Spawns a subagent that runs in its own context and returns a result. This is what delegation needs.
- **Task* family** (`TaskCreate`, `TaskList`, `TaskGet`, `TaskUpdate`, `TaskOutput`, `TaskStop`) = todo-list tracking (the renamed TodoWrite). **Not** subagent dispatch.

Stale docs (superpowers, third-party skills) still write `Task(subagent_type=...)` — that is the OLD API. Translate to `Agent({ subagent_type, description, prompt })`.

## Spawn steps (main session)

1. `Agent` is a **deferred tool**. Load it first with `ToolSearch select:Agent`.
   - The reply `"Tool loaded."` only means "registration attempted." It does **not** prove the tool exists or is callable, and it does not print the schema. **Do not treat it as evidence of availability.** Only a successful real call is evidence.
2. Verify the `subagent_type`. ECC agent type names come from `Skill("ecc:ecc-guide")` — they live in `agents/*.md`, use the **short name** (e.g. `code-architect`, `gan-generator`, `silent-failure-hunter`). **Never guess a type name from memory** — check the registry.
3. Call `Agent({ subagent_type: "<verified-name>", description: "<short>", prompt: "<full self-contained task>" })`.
4. The prompt **must be self-contained** — subagents do not inherit the main session context. Include file paths, the DONE/acceptance criteria, and the verify_command.

## Inside a workflow script

Workflow scripts use their own built-in spawn function, not the `Agent` tool. This skill only governs main-session manual spawns.

## Availability decision rule

A failed spawn ("tool not found" / "unknown subagent_type") does **not** by itself prove the harness lacks subagents — registry listings are unreliable. Re-run `ToolSearch select:Agent`, reconfirm the type via `ecc:ecc-guide`, retry. Only a real failed call after these steps is evidence of unavailability; then fall back to running the work inline in the main session.

Probe to test availability:

```
Agent({ subagent_type: "general-purpose", description: "probe", prompt: "只回复数字 42" })
```

See [REFERENCE.md](REFERENCE.md) for verified type names and full call templates per agent.
