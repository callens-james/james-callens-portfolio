# Safe AI Proof Pack

## What was built
This suite demonstrates a local-first, safety-oriented AI workflow stack:

1. **AI Risk Gate**
   - Policy-based risk classification
   - Confirmation requirements for risky actions
   - Blocklist support
   - JSONL audit logs

2. **Agent Timeline Viewer**
   - Traceability of decisions (task/tool/action/risk)
   - Filtering by risk/tool
   - Summary counts for governance visibility

3. **Eval Harness**
   - Batch evaluation against labeled tasks
   - Pass/fail reliability scoring
   - Latency metrics (including p95)
   - CSV/JSON evidence artifacts

4. **Safe Automation Template**
   - Local-first policy defaults
   - Guard-evaluate / guard-execute pattern
   - Preflight and rollback script scaffolding

---

## Why this matters
This is not a prompt demo. It is an implementation of **safe operational AI patterns**:
- guardrails before execution
- observability and auditability
- measurable reliability
- iterative policy hardening

---

## Metrics progression (evidence)

### Expanded baseline (30 tasks)
- Initial: **29/30** (96.7%), p95 3ms
- After benign-context refinement: **30/30** (100%), p95 3ms

### Adversarial expansion (50 tasks)
- Initial: **49/50** (98.0%), p95 2ms
- After destructive-intent keyword/action refinement: **50/50** (100%), p95 2ms

---

## Refinement example (interview-ready)
- **Observed issue:** A destructive-intent phrasing (“prune db backup table”) scored too low.
- **Action taken:** Added `prune/purge/truncate` to high-risk keywords and `drop-table` to always-confirm actions.
- **Result:** Adversarial run improved from 98.0% to 100.0% with no latency regression.

This shows practical safety engineering: detect edge case → refine policy → re-measure.

---

## Artifact links (in this folder)
- `METRICS_SNAPSHOT_2026-05-01_EXPANDED.md`
- `METRICS_SNAPSHOT_2026-05-02_ADVERSARIAL.md`
- `METRICS_SNAPSHOT_2026-05-02_ADVERSARIAL_REFINED.md`
- Eval reports (`.json` / `.csv`)
- Screenshots (`../screenshots/`)

---

## Local run quickstart
1. Start Risk Gate (`:3344`)
2. Start Timeline Viewer (`:3345`)
3. Run Eval Harness (`:3346`)
4. Review report snapshots and compare trend progression

---

## Positioning statement
I build AI-enabled workflow systems that are **useful, measurable, and safe to operate** in production-minded environments.


## Navigation
- Runbook: `RUNBOOK_SAFE_AI_SUITE.md`
- Failure taxonomy: `FAILURE_TAXONOMY_2026-05-02.md`
- Metrics trend: `METRICS_TREND_TABLE.md`
