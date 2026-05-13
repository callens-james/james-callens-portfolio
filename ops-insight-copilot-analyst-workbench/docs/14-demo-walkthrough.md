# 14 — Demo Walkthrough (Interview-Ready)

## 90-second walkthrough
1. Open dashboard at `:3350`
2. Upload sample CSV (`data/sample/support_export_sample.csv` or `ops_sample_alert.csv`)
3. Show detected format + row normalization metadata
4. Show KPI table and explain values
5. Show anomaly queue (severity + reason)
6. Show recommendation board (priority, rationale)
7. Approve one recommendation, then Undo it to show safety control
8. Generate weekly brief
9. Export KPI CSV + Recommendation CSV
10. Mention audit endpoint (`/api/audit`)

## Talk track
- **Problem:** Manual ops reporting is slow and inconsistent.
- **Build:** Local-first analyst workbench for KPI/anomaly/action workflows.
- **How:** Upload -> normalize -> compute -> detect -> recommend -> approve -> brief/export.
- **Controls:** Deterministic thresholds, approval/undo, audit logs, duplicate-upload dedupe.
- **Business value:** Faster reporting cycle, clearer priorities, and repeatable analyst outputs.

## Suggested sample files
- Primary reviewer demo: `data/sample/ops_sample_alert.csv`
- Source-format demos: `data/sample/support_export_sample.csv`, `data/sample/crm_export_sample.csv`
- Details: [`SAMPLE_DATA.md`](./SAMPLE_DATA.md)

## Expected primary-demo result
Uploading `ops_sample_alert.csv` should produce:
- 3 KPI rows
- 3 anomalies: 2 high, 1 medium
- 3 proposed recommendations
- weekly brief with 3 top actions
- audit entries for upload, recommendation update, and brief generation after approve/undo + brief steps
