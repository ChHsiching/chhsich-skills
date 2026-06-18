---
name: parallel-issue-execution
description: Orchestrate the ultracode dynamic-workflow execution phase — route each Issue to GAN feature implementation or bug-fix, dispatch independent Issues as parallel subagents with file-domain isolation and dependency-aware ordering, write six-element task prompts, and run cross-validation via a code-reviewer subagent. Use when running the ultracode / parallel-Issue execution phase, or orchestrating multiple ECC GAN and review subagents.
---

# Parallel Issue Execution

Orchestration for the execution phase where multiple plan Issues are implemented in parallel. Spawn mechanics live in the `ecc-subagent-invocation` skill — invoke `Skill("ecc-subagent-invocation")` for how to spawn; this skill covers routing, parallel discipline, and cross-validation.

## Task routing

For each Issue in the execution plan:

- **New feature (independent Issue)** → dispatch as a parallel subagent. Implementation via GAN: `Skill("ecc:gan-build")` (drives generator↔evaluator internally), or manually spawn `gan-generator` + `gan-evaluator`. Critical features must complete at least one full generator↔evaluator loop.
- **In-domain bug** (small, confined to one Issue's files, found by a subagent) → that subagent fixes it internally via `Skill("bugfix-discipline")` (which mandates `Skill("diagnosing-bugs")`); do **not** interrupt the workflow.
- **Cross-domain bug** (spans Issues, touches shared modules, or affects other parallel tasks) → **pause the workflow**, return to main session, fix serially, then resume.
- **Needs user input** (e.g. API key) → `AskUserQuestion`; do not stop and wait silently.

For any bug fix, invoke `Skill("bugfix-discipline")`.

## Parallel dispatch discipline

- **Dependency-aware ordering**: read the plan's dependency annotations. Hard dependency (A is prerequisite of B) → serial (A passes cross-validation before B starts). No dependency → parallel.
- **File-domain isolation**: parallel subagents must **never edit the same file**. If two touch overlapping files, the workflow serializes that portion.
- **The main session does the splitting** — not delegated to a lead subagent. Methodology: `superpowers:subagent-driven-development` + `superpowers:dispatching-parallel-agents` (orchestrator dispatches directly, no middle lead layer).

## Six-element task prompt

Every dispatched task prompt must contain all six — self-check before dispatching:

- **WHY** — goal / which Issue / acceptance
- **WHAT** — the concrete change
- **WHERE** — exact file paths
- **HOW MUCH** — scope boundary
- **DONE** — verifiable acceptance + verify_command
- **DON'T** — constraints / out-of-scope / what not to touch

Filled template and GAN role detail in [REFERENCE.md](REFERENCE.md).

## Cross-validation

After each Issue is implemented, an **independent** `code-reviewer` subagent reviews it against that Issue's DONE criteria:

```
Agent({ subagent_type: "code-reviewer", description: "cross-validate <Issue>", prompt: "Against this Issue's DONE criteria, verify: tests actually ran, verify_command exits 0, no regressions. Review only — do not edit." })
```

- Review fails → return to the original executor to redo. The reviewer **must not** edit directly.
- The workflow aggregates each Issue's result + verification status + cross-validation verdict into one report.

## Feature methodology (invoke, don't reproduce)

- TDD loop driver: `Skill("superpowers:test-driven-development")`
- TDD reference (combine with the driver for strict discipline): `Skill("tdd")`
- Design method: `Skill("superpowers:brainstorming")`
- Problem-location method: `Skill("superpowers:systematic-debugging")`
- Anti-false-completion: `Skill("superpowers:verification-before-completion")`
