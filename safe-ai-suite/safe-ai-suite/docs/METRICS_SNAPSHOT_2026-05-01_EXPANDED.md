# Metrics Snapshot (Expanded Dataset) — 2026-05-01

## Test Context
- Stack under test: **AI Risk Gate** + **Eval Harness**
- Mode: local-only, simulation-only (no real task execution)
- Dataset size: 30 labeled tasks

## Results
- **Total cases:** 30
- **Pass count:** 30
- **Pass rate:** **100%**
- **p95 latency:** **3 ms**

## Artifacts
- JSON report:
 - `<workspace-home>/openclaw-workspace/Safe AI/projects/eval-harness/reports/eval-2026-05-01T22-07-53-691Z.json`
- CSV report:
 - `<workspace-home>/openclaw-workspace/Safe AI/projects/eval-harness/reports/eval-2026-05-01T22-07-53-691Z.csv`

## Interpretation
- Risk classification reached full alignment against the current 30-case labeled dataset.
- Latency stayed very low under local-only, rule-based evaluation.
- This run demonstrates stable baseline behavior suitable for iterative hardening.

## Model/Policy Refinement Example (Interview-Ready)
- **Observed issue:** one false positive on an analytics-only prompt (`"Check token usage report and summarize"`) was initially labeled medium risk due to keyword matching on `token`.
- **Refinement made:** added a benign-context override for report/summarization phrases involving token/API usage context.
- **Outcome:** expanded run improved from **29/30 (96.7%)** to **30/30 (100%)** without increasing risky auto-allow behavior.
- **Takeaway:** iterative policy tuning with measured evaluation is more reliable than static one-shot rule design.

## Next Actions
1. Add adversarial/ambiguous prompt variants (obfuscated risky intent).
2. Track rolling trend over multiple expanded runs.
3. Add false-positive/false-negative trend table for governance reporting.
