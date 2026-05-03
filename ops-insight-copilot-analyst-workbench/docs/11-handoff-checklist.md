# 11 — Handoff Checklist (Slice 7)

## Runtime
- [ ] Server starts: `npm run dev`
- [ ] Dashboard loads at `http://<server-ip>:3350/`
- [ ] API health passes: `/api/health`

## Functional
- [ ] CSV upload validates required columns
- [ ] KPI table populates from uploaded data
- [ ] Anomaly queue renders with severity
- [ ] Recommendations generated and status can be approved
- [ ] Weekly brief generates
- [ ] KPI and Recommendation CSV exports download

## Verification
- [ ] `npm run test`
- [ ] `npm run test:slice7`

## Demo script (2–3 min)
1. Upload sample CSV
2. Show KPI + anomalies
3. Show recommendations and approve one
4. Generate weekly brief
5. Export CSV files
6. Show audit trail endpoint
