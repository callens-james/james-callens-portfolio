# Ops Insight Copilot — Proof Pack

This folder captures reviewer-facing validation evidence for the focused refinement cycle.

## Validation commands
Run with the server active:

```bash
npm run dev
npm test
npm run test:slice7
npm run test:e2e
```

## Current proof targets
- `/api/health` returns service OK.
- Core API slice returns 200 for KPIs, anomalies, recommendations, audit, weekly brief, and CSV exports.
- End-to-end demo flow uploads `data/sample/ops_sample_alert.csv` and verifies:
  - 3 KPI rows
  - 3 anomaly records
  - 3 recommendations
  - approve and undo controls
  - weekly brief generation
  - audit events for upload, recommendation update, and brief generation

## Reviewer artifacts
- `docs/REVIEWER_GUIDE.md`
- `docs/PORTFOLIO_ONE_PAGER.md`
- `docs/SAMPLE_DATA.md`
- `docs/14-demo-walkthrough.md`

## Boundary statement
This is a portfolio prototype and local analyst workbench. It is not a production BI platform, does not include live external integrations, and should not be described as deployed or enterprise-ready.
