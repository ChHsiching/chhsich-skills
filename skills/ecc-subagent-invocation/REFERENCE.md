# ECC Subagent Invocation — Reference

Verified ECC `subagent_type` values (short names). Confirm the current set via `Skill("ecc:ecc-guide")` before spawning — the registry is authoritative; this list may lag.

## Architecture / planning
- `code-architect` — architecture review + implementation blueprint of an execution plan.
- `planner` — produce an execution plan.
- `tdd-guide` — background TDD discipline monitor.

## Implementation (GAN)
- `gan-generator` — implement per spec; iterate on evaluator feedback to a quality threshold.
- `gan-evaluator` — score against the Issue's DONE rubric; return actionable feedback.

## Review
- `code-reviewer` — cross-validate an Issue against its DONE criteria (review only, no edits).

## Debugging
- `silent-failure-hunter` — scan for swallowed / silently-caught exceptions.
- `code-explorer` — assess change impact (uses `codegraph_impact`).

## Generic
- `general-purpose` — default; use for the availability probe.

## Call template

```
Agent({
  subagent_type: "<name>",
  description: "<one-line purpose>",
  prompt: "<self-contained task: context + file paths + DONE criteria + verify_command + DON'Ts>"
})
```

## Availability probe

```
Agent({ subagent_type: "general-purpose", description: "probe", prompt: "只回复数字 42" })
```

Returns `42` → Agent is callable in this session.
