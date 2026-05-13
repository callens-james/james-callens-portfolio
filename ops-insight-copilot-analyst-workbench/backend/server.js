const fastify = require('fastify')({ logger: true });
const multipart = require('@fastify/multipart');
const { parse } = require('csv-parse/sync');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const REQUIRED_COLUMNS = ['event_date', 'team', 'metric_name', 'metric_value'];
const DEFAULT_THRESHOLDS = {
  backlog_growth: { warn: 10, high: 20 },
  first_response_time: { warn: 15, high: 30 },
  lead_to_close_days: { warn: 20, high: 35 }
};

const state = {
  uploads: [],
  records: [],
  kpis: [],
  anomalies: [],
  recommendations: [],
  audit: [],
  seenChecksums: new Set(),
  lastUploadMeta: null
};

fastify.register(multipart, { limits: { fileSize: 10 * 1024 * 1024 } });

function addAudit(event_type, entity_type, entity_id, detail = {}) {
  state.audit.push({
    id: crypto.randomUUID(),
    ts: new Date().toISOString(),
    event_type,
    entity_type,
    entity_id,
    detail
  });
}

function diffMinutes(a, b) {
  const x = new Date(a).getTime();
  const y = new Date(b).getTime();
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return (y - x) / 60000;
}

function diffDays(a, b) {
  const x = new Date(a).getTime();
  const y = new Date(b).getTime();
  if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
  return (y - x) / (24 * 60 * 60000);
}

function normalizeRows(rawRows) {
  if (!rawRows.length) return { rows: [], format: 'unknown' };
  const cols = Object.keys(rawRows[0]);

  // Already normalized
  if (REQUIRED_COLUMNS.every(c => cols.includes(c))) {
    return { rows: rawRows, format: 'normalized' };
  }

  // Support ticket export
  if (cols.includes('ticket_id') && cols.includes('created_at') && cols.includes('status')) {
    const byDateTeam = new Map();
    const out = [];
    for (const r of rawRows) {
      const date = String(r.created_at || '').slice(0, 10);
      const team = r.queue || 'Support';
      const key = `${date}|${team}`;
      if (!byDateTeam.has(key)) byDateTeam.set(key, { open: 0 });
      const agg = byDateTeam.get(key);
      if (String(r.status || '').toLowerCase() === 'open') agg.open += 1;

      if (r.first_response_at) {
        const mins = diffMinutes(r.created_at, r.first_response_at);
        if (mins !== null) out.push({ event_date: date, team, metric_name: 'first_response_time', metric_value: mins });
      }
    }
    for (const [k, v] of byDateTeam.entries()) {
      const [event_date, team] = k.split('|');
      out.push({ event_date, team, metric_name: 'backlog_growth', metric_value: v.open });
    }
    return { rows: out, format: 'support_export' };
  }

  // CRM export
  if (cols.includes('lead_id') && cols.includes('created_date')) {
    const out = [];
    for (const r of rawRows) {
      if (!r.close_date) continue;
      const days = diffDays(r.created_date, r.close_date);
      if (days === null) continue;
      out.push({
        event_date: String(r.close_date).slice(0, 10),
        team: r.region || 'Sales',
        metric_name: 'lead_to_close_days',
        metric_value: days
      });
    }
    return { rows: out, format: 'crm_export' };
  }

  // Ops queue aggregate
  if (cols.includes('date') && cols.includes('team') && cols.includes('open_items')) {
    const out = rawRows.map(r => ({
      event_date: r.date,
      team: r.team,
      metric_name: 'backlog_growth',
      metric_value: Number(r.open_items)
    }));
    return { rows: out, format: 'ops_queue_export' };
  }

  return { rows: rawRows, format: 'unknown' };
}

function recomputeKpis() {
  const byMetric = new Map();
  for (const r of state.records) {
    if (!byMetric.has(r.metric_name)) byMetric.set(r.metric_name, []);
    byMetric.get(r.metric_name).push(r.metric_value);
  }

  const snapshotDate = new Date().toISOString().slice(0, 10);
  state.kpis = [...byMetric.entries()].map(([metric_name, values]) => {
    const sum = values.reduce((a, b) => a + b, 0);
    const avg = sum / values.length;
    const min = Math.min(...values);
    const max = Math.max(...values);
    return {
      id: crypto.randomUUID(),
      snapshot_date: snapshotDate,
      kpi_name: metric_name,
      kpi_value: Number(avg.toFixed(2)),
      count: values.length,
      min: Number(min.toFixed(2)),
      max: Number(max.toFixed(2))
    };
  });
}

function recomputeAnomalies() {
  state.anomalies = [];
  for (const k of state.kpis) {
    const t = DEFAULT_THRESHOLDS[k.kpi_name];
    if (!t) continue;

    let severity = null;
    if (k.kpi_value >= t.high) severity = 'high';
    else if (k.kpi_value >= t.warn) severity = 'medium';

    if (severity) {
      state.anomalies.push({
        id: crypto.randomUUID(),
        detected_at: new Date().toISOString(),
        severity,
        metric_name: k.kpi_name,
        observed_value: k.kpi_value,
        threshold_warn: t.warn,
        threshold_high: t.high,
        reason: `${k.kpi_name} is ${k.kpi_value}, threshold warn=${t.warn}, high=${t.high}`,
        status: 'open'
      });
    }
  }
}

function priorityFromSeverity(sev) {
  if (sev === 'high') return 'p1';
  if (sev === 'medium') return 'p2';
  return 'p3';
}

function recommendationTemplate(metric) {
  const map = {
    backlog_growth: {
      title: 'Rebalance queue staffing',
      desc: 'Backlog is rising. Shift capacity and clear aged tickets first.'
    },
    first_response_time: {
      title: 'Tighten first-response SLA plan',
      desc: 'Response times are elevated. Adjust staffing windows and triage routing.'
    },
    lead_to_close_days: {
      title: 'Accelerate sales cycle bottlenecks',
      desc: 'Lead-to-close duration is high. Audit stage transitions and handoffs.'
    }
  };
  return map[metric] || { title: `Investigate ${metric}`, desc: 'Review metric trend and assign an owner.' };
}

function recomputeRecommendations() {
  state.recommendations = state.anomalies.map(a => {
    const tpl = recommendationTemplate(a.metric_name);
    return {
      id: crypto.randomUUID(),
      created_at: new Date().toISOString(),
      priority: priorityFromSeverity(a.severity),
      title: tpl.title,
      description: tpl.desc,
      linked_anomaly_id: a.id,
      status: 'proposed',
      rationale: `${a.metric_name} anomaly (${a.severity}) with observed value ${a.observed_value}`
    };
  });
}

fastify.get('/', async (request, reply) => {
  const htmlPath = path.join(__dirname, '..', 'frontend', 'index.html');
  return reply.type('text/html').send(fs.readFileSync(htmlPath, 'utf8'));
});

fastify.get('/api/health', async () => ({ ok: true, service: 'ops-insight-copilot' }));
fastify.get('/api/kpis', async (request) => {
  const team = request.query?.team;
  if (!team) return state.kpis;

  const filtered = state.records.filter(r => (r.team || '').toLowerCase() === String(team).toLowerCase());
  const grouped = new Map();
  for (const r of filtered) {
    if (!grouped.has(r.metric_name)) grouped.set(r.metric_name, []);
    grouped.get(r.metric_name).push(r.metric_value);
  }
  const snapshot_date = new Date().toISOString().slice(0, 10);
  return [...grouped.entries()].map(([k, vals]) => ({
    id: crypto.randomUUID(),
    snapshot_date,
    kpi_name: k,
    kpi_value: Number((vals.reduce((a,b)=>a+b,0)/vals.length).toFixed(2)),
    count: vals.length,
    min: Number(Math.min(...vals).toFixed(2)),
    max: Number(Math.max(...vals).toFixed(2))
  }));
});
fastify.get('/api/anomalies', async () => state.anomalies);
fastify.get('/api/recommendations', async () => state.recommendations);
fastify.post('/api/recommendations/generate', async () => {
  recomputeRecommendations();
  addAudit('recommendations_generated', 'recommendation', 'batch', { count: state.recommendations.length });
  return { ok: true, count: state.recommendations.length, recommendations: state.recommendations };
});
fastify.patch('/api/recommendations/:id', async (request, reply) => {
  const { id } = request.params;
  const rec = state.recommendations.find(r => r.id === id);
  if (!rec) return reply.code(404).send({ ok: false, error: 'Recommendation not found' });
  const allowed = ['status', 'owner', 'due_date'];
  for (const k of allowed) {
    if (request.body && Object.prototype.hasOwnProperty.call(request.body, k)) rec[k] = request.body[k];
  }
  addAudit('recommendation_updated', 'recommendation', id, { changes: request.body || {} });
  return { ok: true, recommendation: rec };
});
fastify.get('/api/audit', async () => state.audit);

function toCsv(rows, columns) {
  const esc = (v) => {
    const s = String(v ?? '');
    if (/[",\n]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
    return s;
  };
  return [columns.join(','), ...rows.map(r => columns.map(c => esc(r[c])).join(','))].join('\n');
}

fastify.get('/api/export/kpis.csv', async (request, reply) => {
  addAudit('export_generated', 'kpi_snapshot', 'csv', { count: state.kpis.length });
  const csv = toCsv(state.kpis, ['snapshot_date', 'kpi_name', 'kpi_value', 'count', 'min', 'max']);
  reply.header('Content-Type', 'text/csv');
  reply.header('Content-Disposition', 'attachment; filename="kpis.csv"');
  return csv;
});

fastify.get('/api/export/recommendations.csv', async (request, reply) => {
  addAudit('export_generated', 'recommendation', 'csv', { count: state.recommendations.length });
  const csv = toCsv(state.recommendations, ['created_at', 'priority', 'title', 'status', 'rationale']);
  reply.header('Content-Type', 'text/csv');
  reply.header('Content-Disposition', 'attachment; filename="recommendations.csv"');
  return csv;
});

fastify.get('/api/brief/weekly', async () => {
  const totalAnom = state.anomalies.length;
  const high = state.anomalies.filter(a => a.severity === 'high').length;
  const medium = state.anomalies.filter(a => a.severity === 'medium').length;
  const approved = state.recommendations.filter(r => r.status === 'approved').length;
  const top = state.recommendations
    .slice()
    .sort((a, b) => (a.priority > b.priority ? 1 : -1))
    .slice(0, 3)
    .map(r => `- [${r.priority}] ${r.title} (${r.status})`)
    .join('\n');

  const brief = [
    `Weekly Ops Brief (${new Date().toISOString().slice(0,10)})`,
    `KPIs tracked: ${state.kpis.length}`,
    `Anomalies: ${totalAnom} (high=${high}, medium=${medium})`,
    `Recommendations: ${state.recommendations.length} (approved=${approved})`,
    '',
    'Top Actions:',
    top || '- None'
  ].join('\n');

  addAudit('brief_generated', 'weekly_brief', 'current', { anomalies: totalAnom, recommendations: state.recommendations.length });
  return { ok: true, brief };
});

fastify.get('/api/uploads', async () => state.uploads);
fastify.get('/api/upload/last', async () => state.lastUploadMeta || { ok: true, message: 'No uploads yet' });

fastify.post('/api/upload', async (request, reply) => {
  const file = await request.file();
  if (!file) return reply.code(400).send({ ok: false, error: 'No file uploaded' });

  const filename = file.filename || 'unknown.csv';
  if (!filename.toLowerCase().endsWith('.csv')) {
    return reply.code(400).send({ ok: false, error: 'Only CSV files are supported in v1' });
  }

  const buffer = await file.toBuffer();
  const text = buffer.toString('utf8');

  let rawRows;
  try {
    rawRows = parse(text, { columns: true, skip_empty_lines: true, trim: true });
  } catch (err) {
    return reply.code(400).send({ ok: false, error: `CSV parse error: ${err.message}` });
  }

  if (!rawRows.length) return reply.code(400).send({ ok: false, error: 'CSV has no data rows' });

  const sourceColumns = Object.keys(rawRows[0]);
  const normalized = normalizeRows(rawRows);
  const rows = normalized.rows;

  if (!rows.length) {
    return reply.code(400).send({ ok: false, error: `No usable rows after normalization (${normalized.format})` });
  }

  const columns = Object.keys(rows[0]);
  const missing = REQUIRED_COLUMNS.filter(c => !columns.includes(c));
  if (missing.length) {
    return reply.code(400).send({
      ok: false,
      error: 'Missing required columns after normalization',
      formatDetected: normalized.format,
      required: REQUIRED_COLUMNS,
      missing
    });
  }

  const badMetricRows = [];
  rows.forEach((r, idx) => {
    const n = Number(r.metric_value);
    if (!Number.isFinite(n)) badMetricRows.push(idx + 2);
    else r.metric_value = n;
  });

  if (badMetricRows.length) {
    return reply.code(400).send({
      ok: false,
      error: 'Invalid metric_value in one or more rows',
      rowNumbers: badMetricRows.slice(0, 20)
    });
  }

  const uploadId = crypto.randomUUID();
  const uploadedAt = new Date().toISOString();
  const checksum = crypto.createHash('sha256').update(buffer).digest('hex');

  const duplicate = state.seenChecksums.has(checksum);

  if (!duplicate) {
    state.seenChecksums.add(checksum);
    state.uploads.push({
      id: uploadId,
      filename,
      uploaded_at: uploadedAt,
      row_count: rows.length,
      source_row_count: rawRows.length,
      format_detected: normalized.format,
      source_columns: sourceColumns,
      columns,
      checksum
    });

    rows.forEach(r => {
      state.records.push({
        id: crypto.randomUUID(),
        upload_id: uploadId,
        event_date: r.event_date,
        team: r.team,
        metric_name: r.metric_name,
        metric_value: r.metric_value
      });
    });
  }

  recomputeKpis();
  recomputeAnomalies();
  recomputeRecommendations();

  addAudit('upload_processed', 'source_upload', uploadId, {
    filename,
    row_count: rows.length,
    checksum,
    duplicate,
    kpi_count: state.kpis.length,
    anomaly_count: state.anomalies.length,
    recommendation_count: state.recommendations.length
  });

  state.lastUploadMeta = {
    formatDetected: normalized.format,
    sourceRows: rawRows.length,
    rowsAccepted: rows.length,
    duplicate
  };

  return {
    ok: true,
    duplicate,
    upload: state.uploads[state.uploads.length - 1] || null,
    validation: {
      requiredColumns: REQUIRED_COLUMNS,
      missing: [],
      formatDetected: normalized.format,
      sourceRows: rawRows.length,
      rowsAccepted: rows.length
    }
  };
});

fastify.listen({ port: 3350, host: '0.0.0.0' }).catch(err => {
  console.error(err);
  process.exit(1);
});
