---
name: bugfix-discipline
description: Apply the mandatory bug-fix protocol — drive diagnosis via the diagnose skill, scan for silently-swallowed exceptions, escalate to systematic-debugging after repeated failures, make surgical edits, then verify with quality-gate and impact analysis. Use when fixing any bug, debugging a failure, or running regression after a fix.
---

# Bugfix Discipline

Protocol for fixing a bug in the main session, run **serially** — bug fixes do **not** run inside the parallel workflow (see `parallel-issue-execution` for when a bug interrupts the workflow). Use the native `Agent` tool for any subagent work here.

## Mandate

**Always invoke `Skill("diagnose")` and run the six-phase method below. Do not skip diagnosis and jump to editing.** The six phases mirror the diagnose skill; they are reproduced here so the full protocol lives in one place and is not lost.

## The six phases (diagnose method)

### Phase 1: Build a feedback loop
- Write a test / curl / script that reliably reproduces the bug.
- Priority: failing test > HTTP script > CLI call > headless browser > other.

### Phase 2: Reproduce
- Confirm it is the bug the user described, not a nearby different bug.

### Phase 3: Hypothesize
- 3–5 ranked, falsifiable hypotheses.
- Format: "If <X> is the cause, then <changing Y> makes the bug disappear."

### Phase 4: Verify the hypothesis
- Change one variable at a time; tag debug logs with `[DEBUG-xxxx]`.

### Phase 5: Fix + regression test
- Write the regression test first (watch it fail) → apply the fix → watch it pass.
- No clean seam to test against → record the finding; the architecture blocks the bug from being pinned down.

### Phase 6: Clean up + retrospective
- [ ] Original reproduction no longer reproduces.
- [ ] Regression test passes.
- [ ] All `[DEBUG-xxx]` removed.
- [ ] Correct hypothesis written into the commit message.
- [ ] Answer: what would have prevented this bug?

## Surrounding ECC tools (compose with diagnose)

- **Swallowed-exception scan** (full call):

  ```
  Agent({ subagent_type: "silent-failure-hunter", description: "scan swallowed exceptions", prompt: "Scan the modules touched by this bug (<paths>). Find exceptions caught/excepted but not logged, not reported, or swallowed by an empty except. Output: location + current handling + suggestion. Do not edit code." })
  ```

- **Escalation**: 3+ failed fix attempts → `Skill("superpowers:systematic-debugging")` to question the architecture itself (the bug may be a symptom of a deeper structural issue).
- **Surgical edits**: `Skill("andrej-karpathy-skills:karpathy-guidelines")` — minimal changes, no over-refactor.

## Before declaring fixed

- `Skill("superpowers:verification-before-completion")` — no false "fixed"; evidence required.
- Run `Skill("ecc:quality-gate")` to confirm no new problems introduced.
- Impact analysis (full call):

  ```
  Agent({ subagent_type: "code-explorer", description: "assess impact", prompt: "Analyze the blast radius of this change; using codegraph_impact, list the affected callers and output the scope that needs regression. Do not edit code." })
  ```

  then run the relevant test suites.

## Non-negotiables

- No skip-to-edit. Diagnose (six phases) first.
- Regression test written before the fix (watch it fail), then the fix (watch it pass).
- Remove all `[DEBUG-xxx]` markers before done.
- The correct hypothesis goes into the commit message.
- Answer: what would have prevented this bug?
