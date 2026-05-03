# Metrics Snapshot — 2026-05-01

## Test Context
- Stack under test: **AI Risk Gate** + **Eval Harness**
- Mode: local-only
- Dataset size: 5 labeled tasks (`datasets/tasks.json`)

## Results
- **Total cases:** 5
- **Pass count:** 5
- **Pass rate:** **100%**
- **p95 latency:** **4 ms**

## Artifacts
- JSON report:
  - `/home/james/openclaw-workspace/Safe AI/projects/eval-harness/reports/eval-2026-05-01T20-40-48-698Z.json`
- CSV report:
  - `/home/james/openclaw-workspace/Safe AI/projects/eval-harness/reports/eval-2026-05-01T20-40-48-698Z.csv`

## Interpretation
- Policy-based risk labeling matched all expected labels in this starter dataset.
- Latency is currently very low due to local-only, rule-based evaluation.
- This provides strong baseline evidence for safe-execution gating behavior.

## Next Steps
1. Expand dataset from 5 to 50+ cases (include edge cases and ambiguous prompts).
2. Add adversarial tests (prompt injection style wording, obfuscated risky intent).
3. Track trend metrics over multiple runs (daily/weekly pass-rate and latency drift).
4. Add false-positive/false-negative analysis table.
