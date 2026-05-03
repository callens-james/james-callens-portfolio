CREATE TABLE IF NOT EXISTS source_upload(id TEXT PRIMARY KEY, filename TEXT, uploaded_at TEXT);
CREATE TABLE IF NOT EXISTS kpi_snapshot(id TEXT PRIMARY KEY, snapshot_date TEXT, kpi_name TEXT, kpi_value REAL);
CREATE TABLE IF NOT EXISTS anomaly(id TEXT PRIMARY KEY, detected_at TEXT, severity TEXT, metric_name TEXT, observed_value REAL, reason TEXT);
CREATE TABLE IF NOT EXISTS recommendation(id TEXT PRIMARY KEY, created_at TEXT, priority TEXT, title TEXT, status TEXT, rationale TEXT);
CREATE TABLE IF NOT EXISTS audit_event(id TEXT PRIMARY KEY, ts TEXT, event_type TEXT, entity_type TEXT, entity_id TEXT, detail_json TEXT);
