const http = require('http');
const fs = require('fs');
const path = require('path');

const BASE = 'http://127.0.0.1:3350';

function request(method, route, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(route, BASE);
    const req = http.request(url, { method, headers }, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function getJson(route) {
  const res = await request('GET', route);
  if (res.status !== 200) throw new Error(`${route} expected 200 got ${res.status}`);
  return JSON.parse(res.data);
}

async function patchJson(route, payload) {
  const body = JSON.stringify(payload);
  const res = await request('PATCH', route, body, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body)
  });
  if (res.status !== 200) throw new Error(`${route} expected 200 got ${res.status}: ${res.data}`);
  return JSON.parse(res.data);
}

async function uploadCsv(filePath) {
  const boundary = '----ops-insight-test-boundary';
  const csv = fs.readFileSync(filePath);
  const filename = path.basename(filePath);
  const head = Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${filename}"\r\nContent-Type: text/csv\r\n\r\n`);
  const tail = Buffer.from(`\r\n--${boundary}--\r\n`);
  const body = Buffer.concat([head, csv, tail]);
  const res = await request('POST', '/api/upload', body, {
    'Content-Type': `multipart/form-data; boundary=${boundary}`,
    'Content-Length': body.length
  });
  if (res.status !== 200) throw new Error(`/api/upload expected 200 got ${res.status}: ${res.data}`);
  return JSON.parse(res.data);
}

(async () => {
  await getJson('/api/health');

  const sample = path.join(__dirname, '..', 'data', 'sample', 'ops_sample_alert.csv');
  const upload = await uploadCsv(sample);
  if (!upload.ok) throw new Error('upload did not return ok=true');
  if (upload.validation.formatDetected !== 'normalized') throw new Error('expected normalized sample format');
  if (upload.validation.rowsAccepted !== 3) throw new Error('expected 3 accepted rows');

  const kpis = await getJson('/api/kpis');
  const anomalies = await getJson('/api/anomalies');
  const recos = await getJson('/api/recommendations');
  if (kpis.length < 3) throw new Error(`expected at least 3 KPIs, got ${kpis.length}`);
  if (anomalies.length < 3) throw new Error(`expected at least 3 anomalies, got ${anomalies.length}`);
  if (recos.length < 3) throw new Error(`expected at least 3 recommendations, got ${recos.length}`);
  if (!anomalies.some(a => a.severity === 'high')) throw new Error('expected at least one high severity anomaly');

  const first = recos[0];
  const approved = await patchJson(`/api/recommendations/${first.id}`, { status: 'approved' });
  if (approved.recommendation.status !== 'approved') throw new Error('approve step failed');
  const undone = await patchJson(`/api/recommendations/${first.id}`, { status: 'proposed' });
  if (undone.recommendation.status !== 'proposed') throw new Error('undo step failed');

  const brief = await getJson('/api/brief/weekly');
  if (!brief.brief.includes('Weekly Ops Brief')) throw new Error('brief text missing heading');

  const audit = await getJson('/api/audit');
  if (!audit.some(e => e.event_type === 'upload_processed')) throw new Error('audit missing upload_processed');
  if (!audit.some(e => e.event_type === 'recommendation_updated')) throw new Error('audit missing recommendation_updated');
  if (!audit.some(e => e.event_type === 'brief_generated')) throw new Error('audit missing brief_generated');

  console.log(JSON.stringify({
    ok: true,
    sample: 'data/sample/ops_sample_alert.csv',
    kpis: kpis.length,
    anomalies: anomalies.length,
    recommendations: recos.length,
    auditEvents: audit.length,
    controlsVerified: ['upload_validation', 'anomaly_detection', 'recommendation_approve', 'recommendation_undo', 'brief_generation', 'audit_logging']
  }, null, 2));
})().catch(err => {
  console.error(err.message || err);
  process.exit(1);
});
