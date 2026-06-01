# Reviewer Guide — Ops Insight Copilot

## What it is
Ops Insight Copilot is a local-first analyst workbench that turns common operations CSV exports into a repeatable decision workflow:

`CSV upload → validation/normalization → KPI snapshot → anomaly flags → recommended actions → approval/undo → weekly brief/export`

It is intentionally small: a reviewer should be able to understand and run the demo in a few minutes.

## Problem solved
Operations teams often export data from support, CRM, or queue tools and manually rebuild the same weekly view: what changed, what is risky, what needs action, and what should be reported upward. This project standardizes that workflow with deterministic, auditable logic.

## Fast demo
```bash
cd ops-insight-copilot-analyst-workbench
npm install
npm run dev
```

Open:

```text
http://127.0.0.1:3350/
```

Use the demo file:

```text
data/sample/ops_sample_alert.csv
```

Demo path:
1. Upload `ops_sample_alert.csv`.
2. Confirm three KPI rows appear.
3. Confirm anomaly queue shows two high severity and one medium severity issue.
4. Confirm three proposed recommendations appear.
5. Approve one recommendation, then undo it.
6. Generate Weekly Brief.
7. Export KPI CSV and Recommendation CSV.
8. Mention `/api/audit` as the traceability endpoint.

## What proves it works
Run these while the server is active:

```bash
npm test
npm run test:slice7
npm run test:e2e
```

Expected proof points:
- health endpoint returns OK
- core API endpoints respond
- upload validation accepts the sample CSV
- KPI, anomaly, and recommendation outputs are generated
- approve/undo control works
- weekly brief is generated
- audit log records upload, recommendation update, and brief generation events

## Sample data
- `data/sample/ops_sample_alert.csv` — normalized sample designed to trigger visible alerts.
- `data/sample/ops_sample.csv` — normalized lower-noise baseline.
- `data/sample/support_export_sample.csv` — support-ticket style source export.
- `data/sample/crm_export_sample.csv` — CRM lead export style source file.

## Reviewer positioning
This is not trying to be a full BI suite. It demonstrates practical AI-adjacent product engineering: data intake, normalization, explainable rules, dashboard UX, human-in-the-loop controls, auditability, and exportable operator artifacts.

## Claims to make
- Local-first analyst workbench for operations CSVs.
- Deterministic KPI/anomaly/recommendation pipeline.
- Human approval/undo and audit logging.
- Reviewer-ready demo and validation flow.

## Claims to avoid
- Do not claim production deployment.
- Do not claim ML forecasting or full BI replacement.
- Do not claim real CRM/helpdesk integrations.
- Do not claim enterprise auth or multi-tenant readiness.
