# Sample Data Guide

Ops Insight Copilot includes intentionally small CSV fixtures so reviewers can see the full workflow quickly.

## Recommended reviewer sample

### `data/sample/ops_sample_alert.csv`
Normalized metric rows that intentionally trigger visible alerts.

Expected output after upload:
- KPI rows: `backlog_growth`, `first_response_time`, `lead_to_close_days`
- Anomalies: 2 high severity, 1 medium severity
- Recommendations: 3 proposed actions
- Weekly brief: 3 KPIs tracked, 3 anomalies, 3 recommendations

Use this for the main demo.

## Other samples

### `data/sample/ops_sample.csv`
Normalized operations metrics with lower values. Useful as a simple baseline fixture.

### `data/sample/support_export_sample.csv`
Support-ticket shaped export. Demonstrates source normalization from ticket rows into operational metrics.

### `data/sample/crm_export_sample.csv`
CRM lead export shaped file. Demonstrates conversion into lead-to-close timing metrics.

## Why the files are tiny
The goal is reviewer clarity, not dataset size. The sample files are small enough to inspect manually while still exercising upload validation, source-format detection, normalization, KPI aggregation, anomaly detection, recommendations, brief generation, exports, and audit logging.
