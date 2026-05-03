# 12 — Interview Script (Problem → Build → How → Controls → Value)

## 90-second version
**Problem:** Ops teams export data from support/CRM tools, then spend too much time manually cleaning, comparing, and writing weekly updates.

**What I built:** I built **Ops Insight Copilot**, a local-first analyst workbench that converts raw CSV exports into KPI trends, anomaly flags, and prioritized recommendations.

**How it works:** You upload CSV, the app validates and normalizes records, computes KPIs, runs threshold-based anomaly detection, generates recommendations, and produces a weekly brief + CSV exports.

**Metrics/controls:** It has explicit thresholds, severity/priority mapping, approve-before-action workflow, and audit logging for traceability. It also handles multiple source formats (normalized, support export, CRM export) and dedupes duplicate uploads.

**Why company can use it:** It shortens reporting cycle time, standardizes decision quality, and gives leadership consistent action-oriented summaries without adding paid AI dependencies.

## 3-minute version (talk track)
1. Business pain and manual workflow bottlenecks
2. Architecture and local-first rationale
3. Demo flow: upload → KPI → anomaly → recommendations → brief/export
4. Controls: human-in-the-loop approvals, audit events, deterministic rules
5. Measured outcomes and extension path (DB persistence, role-based access, scheduling)
