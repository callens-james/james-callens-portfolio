# Ops Insight Copilot — Analyst Workbench

## One-line summary
Ops Insight Copilot turns operations CSV exports into KPI snapshots, anomaly alerts, recommended actions, weekly briefs, exports, and audit evidence.

## Problem solved
Operations teams often prepare weekly updates by manually cleaning CSV exports, checking metrics, deciding what changed, and writing action summaries. That creates slow, inconsistent, hard-to-audit reporting.

## What it does
- Accepts small operations CSV exports.
- Validates and normalizes source formats.
- Computes KPI summaries.
- Flags explainable threshold-based anomalies.
- Generates prioritized recommendations.
- Supports human approve/undo controls.
- Produces weekly brief and CSV exports.
- Records audit events for traceability.

## Reviewer path
Start here:

- Project folder: [`../ops-insight-copilot-analyst-workbench/`](../ops-insight-copilot-analyst-workbench/)
- Reviewer guide: [`../ops-insight-copilot-analyst-workbench/docs/REVIEWER_GUIDE.md`](../ops-insight-copilot-analyst-workbench/docs/REVIEWER_GUIDE.md)
- Portfolio one-pager: [`../ops-insight-copilot-analyst-workbench/docs/PORTFOLIO_ONE_PAGER.md`](../ops-insight-copilot-analyst-workbench/docs/PORTFOLIO_ONE_PAGER.md)
- Proof pack: [`../ops-insight-copilot-analyst-workbench/release/proof-pack/README.md`](../ops-insight-copilot-analyst-workbench/release/proof-pack/README.md)

## Demo sample
Use:

```text
ops-insight-copilot-analyst-workbench/data/sample/ops_sample_alert.csv
```

Expected demo outcome:
- 3 KPI rows
- 3 anomaly flags
- 3 proposed recommendations
- weekly brief with top actions
- audit evidence for upload, approval/undo, and brief generation

## Validation evidence
The proof pack includes validation output for:

```bash
npm test
npm run test:slice7
npm run test:e2e
```

The end-to-end demo test verifies upload validation, KPI generation, anomaly detection, recommendation generation, approve/undo control, weekly brief generation, and audit logging.

## Portfolio positioning
This project is strongest as a business-operations complement to AppSec Red Team Copilot:

- AppSec shows governed security automation.
- Ops Insight shows analyst workflow automation and operational decision support.

## Boundaries / claims to avoid
Do not describe this as:
- production deployed
- a full BI platform
- a live CRM/helpdesk integration
- ML forecasting
- enterprise auth or multi-tenant ready

Best framing: local-first portfolio prototype demonstrating practical workflow automation, explainable rules, human controls, and reviewer-ready proof.
