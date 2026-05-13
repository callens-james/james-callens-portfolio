# Portfolio One-Pager — Ops Insight Copilot

## Short description
Ops Insight Copilot is a local-first analyst workbench that converts operations CSV exports into KPI snapshots, anomaly alerts, recommended actions, weekly executive briefs, exports, and audit evidence.

## Problem
Teams often rely on ad hoc spreadsheet work to prepare weekly operations updates. That makes reporting slow, inconsistent, and hard to audit.

## Solution
The app provides a repeatable workflow:

1. Upload CSV exports.
2. Validate and normalize source rows.
3. Compute KPI summaries.
4. Flag threshold-based anomalies.
5. Generate prioritized recommendations.
6. Approve or undo recommendations.
7. Produce weekly brief and CSV exports.
8. Preserve audit trail events.

## Built capabilities
- Fastify/Node backend with local dashboard frontend.
- CSV upload and source-format normalization.
- KPI aggregation for operational metrics.
- Explainable anomaly thresholds.
- Recommendation generation tied to anomalies.
- Human-in-the-loop approve/undo controls.
- Weekly brief generation.
- CSV exports and audit endpoint.
- Smoke, API slice, and end-to-end demo-flow tests.

## Demo proof
Primary demo sample:

```text
data/sample/ops_sample_alert.csv
```

Expected result:
- 3 KPI rows
- 3 anomaly flags
- 3 recommendations
- weekly brief with top actions
- audit events for upload, approval/undo, and brief generation

Validation commands:

```bash
npm test
npm run test:slice7
npm run test:e2e
```

## Interview framing
“I built a local analyst workbench that turns raw operations exports into a repeatable weekly decision workflow. It normalizes CSV inputs, computes KPIs, flags threshold-based anomalies, proposes prioritized actions, and creates a weekly brief with exports and audit evidence. The focus was not flashy automation — it was making analyst work faster, more consistent, and easier to trust.”

## Best-fit roles/signals
- Data Analyst / Business Operations Analyst
- AI Enablement / AI Ops
- Product-minded full-stack engineering
- Workflow automation with human controls

## Boundaries
This is a portfolio prototype, not a production BI platform. It does not include live third-party integrations, enterprise auth, multi-tenant permissions, or ML forecasting.
