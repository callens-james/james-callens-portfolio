# Ops Insight Copilot (Analyst Workbench)

Local-first analyst dashboard that converts raw operations exports into:
- KPI trends
- anomaly alerts
- prioritized recommendations
- weekly executive brief
- audit/export artifacts

**One-line outcome:** a reviewer can upload one CSV and see the complete analyst workflow — KPI snapshot, anomaly queue, recommended actions, approval/undo control, weekly brief, exports, and audit trail — in a few minutes.

## Why this project exists
Ops teams often export CSVs from support/CRM systems and then manually clean, analyze, and summarize. This tool standardizes that flow and speeds decision-making with human-in-the-loop controls.

It is intentionally bounded: this is a portfolio-grade analyst workbench, not a full BI platform or live CRM/helpdesk integration.

## Core capabilities
1. **CSV upload + validation**
2. **Auto-normalization** from multiple source formats:
   - normalized metrics CSV
   - support ticket export
   - CRM lead export
   - ops queue export
3. **KPI computation** (avg/min/max/count)
4. **Anomaly detection** (threshold-based, explainable)
5. **Recommendation generation** (priority + rationale)
6. **Approval + Undo** for recommendations
7. **Weekly brief generation**
8. **CSV exports + audit logging**

## Run
```bash
cd ops-insight-copilot-analyst-workbench
npm install
npm run dev
```
Open: `http://<server-ip>:3350/`

## Fast reviewer demo
Use:

```text
data/sample/ops_sample_alert.csv
```

Expected result:
- 3 KPI rows
- 3 anomaly flags
- 3 recommendations
- weekly brief with top actions
- audit events for upload, approve/undo, and brief generation

## Test / validation
Start the server first (`npm run dev`), then run:

```bash
npm run test
npm run test:slice7
npm run test:e2e
```

## Reviewer assets
- Reviewer guide: [`docs/REVIEWER_GUIDE.md`](./docs/REVIEWER_GUIDE.md)
- Portfolio one-pager: [`docs/PORTFOLIO_ONE_PAGER.md`](./docs/PORTFOLIO_ONE_PAGER.md)
- Sample data guide: [`docs/SAMPLE_DATA.md`](./docs/SAMPLE_DATA.md)
- Screenshot guide: [`docs/SCREENSHOTS.md`](./docs/SCREENSHOTS.md)
- Walkthrough: [`docs/14-demo-walkthrough.md`](./docs/14-demo-walkthrough.md)
- Proof pack: [`release/proof-pack/README.md`](./release/proof-pack/README.md)

## Lifecycle docs
Use docs/00..11 for full thought-to-finale process and handoff.
