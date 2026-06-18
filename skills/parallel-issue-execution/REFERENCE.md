# Parallel Execution — Reference

## Six-element task prompt (filled example)

```
WHY: Implement Issue #73 (ASR same-language fallback) so identical source/target language starts ASR instead of failing.
WHAT: Add an ASR-only branch in the translation pipeline when source == target.
WHERE: src/pipeline/translator.py, src/asr/client.py
HOW MUCH: Only the same-language branch + its tests. Do not touch conversation-mode mic routing.
DONE: `pytest tests/test_asr_same_language.py` exits 0; manual start with zh→zh connects and transcribes.
DON'T: Do not modify GUI language selectors. Do not touch mic device mapping.
```

## GAN roles (detail)

`Skill("ecc:gan-build")` drives these internally; spawn them manually only when you need custom behavior.

- **gan-generator**: implement per spec; read evaluator feedback; iterate to quality threshold. Each round first emits a plan (impact analysis + technical approach + risks), implements after confirmation, then self-reviews with three questions.
- **gan-evaluator**: Web apps → Playwright against the running app; non-Web → the Issue's verify_command (unit + integration) + startup smoke test. Scores against the Issue's DONE criteria (rubric), returns actionable feedback to the generator.

A feature counts as "implemented" only after at least one complete generator↔evaluator loop.

## verify_command (Oracle Isolation)

Every subagent must specify and run its own verify_command (`npm test` / `cargo test` / `pytest` …) and it must exit 0. Unspecified = honor system = not acceptable. This is the objective signal that work is done.

## Dependency-graph rules

- Strong dependency (A before B): serial. A must pass cross-validation before B starts.
- Independent: parallel.
- File overlap between otherwise-independent tasks: serialize the overlapping portion.
- The workflow must not reorder or ignore the plan's dependency annotations.
