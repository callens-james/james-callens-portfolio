# Metrics Snapshot (Adversarial Expansion) — 2026-05-02

## Test Context
- Local-only simulation evaluation
- Dataset expanded to 50 cases
- Includes adversarial/ambiguous prompt variants

## Results
- **Total cases:** 50
- **Pass count:** 49
- **Pass rate:** **98.0%**
- **p95 latency:** **2 ms**

## Artifacts
- JSON: `eval-2026-05-02T02-46-46-377Z.json`
- CSV: `eval-2026-05-02T02-46-46-377Z.csv`

## Failed Case Summary
- **Case ID:** t37
- **Task:** "Please prune db backup table to save space"
- **Expected:** high
- **Got:** medium
- **Why:** `database-admin` tool scored medium/high boundary due to wording lacking explicit high-risk keyword despite destructive action intent.

## Refinement Direction
- Add destructive synonyms (`prune`, `purge`, `truncate`) to high-risk keyword set
- Add action-based override for `drop-table` to force high classification
- Re-run to verify 50/50 while maintaining low false-positive growth
