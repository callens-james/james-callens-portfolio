# Validation Evidence — Ops Insight Copilot

Generated: 2026-05-13T01:16:30Z

## Commands
```text
npm test

> ops-insight-copilot-analyst-workbench@0.1.0 test
> node tests/smoke.test.js

smoke ok

npm run test:slice7

> ops-insight-copilot-analyst-workbench@0.1.0 test:slice7
> node tests/slice7.test.js

OK /api/health
OK /api/kpis
OK /api/anomalies
OK /api/recommendations
OK /api/audit
OK /api/brief/weekly
OK /api/export/kpis.csv
OK /api/export/recommendations.csv
slice7 test pack: PASS

npm run test:e2e

> ops-insight-copilot-analyst-workbench@0.1.0 test:e2e
> node tests/e2e_demo_flow.test.js

{
  "ok": true,
  "sample": "data/sample/ops_sample_alert.csv",
  "kpis": 3,
  "anomalies": 3,
  "recommendations": 3,
  "auditEvents": 13,
  "controlsVerified": [
    "upload_validation",
    "anomaly_detection",
    "recommendation_approve",
    "recommendation_undo",
    "brief_generation",
    "audit_logging"
  ]
}
```
