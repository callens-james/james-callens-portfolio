# Metrics Trend Table

| Run Date | Dataset Size | Pass Count | Pass Rate | p95 Latency (ms) | Note |
|---|---:|---:|---:|---:|---|
| 2026-05-01 | 5 | 5 | 100.0% | 4 | Initial baseline run |
| 2026-05-01 (expanded) | 30 | 29 | 96.7% | 3 | Found benign-context false positive |
| 2026-05-01 (expanded refined) | 30 | 30 | 100.0% | 3 | Added benign-context override (`token usage report`) |
| 2026-05-02 (adversarial) | 50 | 49 | 98.0% | 2 | Found destructive-intent phrasing miss |
| 2026-05-02 (adversarial refined) | 50 | 50 | 100.0% | 2 | Added `prune/purge/truncate` + `drop-table` always-confirm |

## Interpretation
- Reliability remained high while dataset complexity increased.
- Refinements were targeted and measurable.
- Latency remained stable/low despite expanded evaluation volume.

## Interview framing
This table demonstrates an evidence-driven loop:
1. Evaluate at baseline
2. Detect edge cases
3. Refine policy
4. Re-run and verify improvement
| 2026-05-02 (auto) | 50 | 50 | 100.0% | 2 | Weekly auto refresh |
