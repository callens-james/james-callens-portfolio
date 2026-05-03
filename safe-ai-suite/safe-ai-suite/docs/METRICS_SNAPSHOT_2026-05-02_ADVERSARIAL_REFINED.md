# Metrics Snapshot (Adversarial + Refinement) — 2026-05-02

## Test Context
- Local-only simulation evaluation
- Dataset: 50 cases (includes adversarial/ambiguous prompts)
- Policy refinement applied after one failure in prior run

## Results
- **Total cases:** 50
- **Pass count:** 50
- **Pass rate:** **100.0%**
- **p95 latency:** **2 ms**

## Refinement Applied
- Added destructive synonyms to high-risk keywords: `prune`, `purge`, `truncate`
- Added `drop-table` to `alwaysConfirmActions` to force high/confirm behavior

## Outcome
- Previous run: 49/50 (98.0%)
- Refined run: 50/50 (100.0%)
- No latency regression observed.

## Artifacts
- JSON: `eval-2026-05-02T02-50-29-576Z.json`
- CSV: `eval-2026-05-02T02-50-29-576Z.csv`
