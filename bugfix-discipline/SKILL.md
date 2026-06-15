---
name: bugfix-discipline
description: Apply the mandatory bug-fix protocol — drive diagnosis via the diagnose skill, scan for silently-swallowed exceptions, escalate to systematic-debugging after repeated failures, make surgical edits, then verify with quality-gate and impact analysis. Use when fixing any bug, debugging a failure, or running regression after a fix.
---

# Bugfix Discipline

Protocol for fixing a bug in the main session (serial — bug fixes do not run inside the parallel workflow; see `parallel-issue-execution` for when a bug interrupts the workflow).

## Mandate

**Always invoke `Skill("diagnose")` to drive the fix.** Do not skip diagnosis and jump to editing. The diagnose skill carries the full method (reproduce → confirm → hypothesize → verify → fix + regression → cleanup); do not re-document it here.

## Surrounding ECC tools (compose with diagnose)

- **Swallowed-exception scan**:

  ```
  Agent({ subagent_type: "silent-failure-hunter", description: "scan swallowed exceptions", prompt: "Scan the modules touched by this bug (<paths>). Find exceptions caught/excepted but not logged, not reported, or swallowed by empty except. Output location + current handling + suggestion. Do not edit code." })
  ```

- **Escalation**: 3+ failed fix attempts → `Skill("superpowers:systematic-debugging")` to question the architecture itself (the bug may be a symptom of a deeper structural issue).
- **Surgical edits**: `Skill("andrej-karpathy-skills:karpathy-guidelines")` — minimal changes, no over-refactor.

## Before declaring fixed

- `Skill("superpowers:verification-before-completion")` — no false "fixed"; evidence required.
- Run `Skill("ecc:quality-gate")` to confirm no new problems introduced.
- Impact analysis:

  ```
  Agent({ subagent_type: "code-explorer", description: "assess impact", prompt: "Using codegraph_impact, list callers affected by this change and output the scope needing regression. Do not edit code." })
  ```

  then run the relevant test suites.

## Non-negotiables

- No skip-to-edit. Diagnose first.
- Regression test written before the fix (watch it fail), then the fix (watch it pass).
- Remove all `[DEBUG-xxx]` markers before done.
- The correct hypothesis goes into the commit message.
- Answer: what would have prevented this bug?
