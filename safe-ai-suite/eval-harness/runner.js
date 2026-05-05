const fs = require('fs');
const path = require('path');

const dataset = JSON.parse(fs.readFileSync(path.join(__dirname, 'datasets/tasks.json'),'utf8'));
const API = process.env.RISK_GATE_URL || 'http://127.0.0.1:3344/api/evaluate';

async function run() {
 const rows = [];
 for (const t of dataset) {
 const start = Date.now();
 let ok=false, got='error', requiresConfirmation=false, score=null, err='';
 try {
 const res = await fetch(API, {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(t)});
 const data = await res.json();
 got = data?.decision?.riskLevel || 'unknown';
 requiresConfirmation = !!data?.decision?.requiresConfirmation;
 score = data?.decision?.score ?? null;
 ok = got === t.expectedRisk;
 } catch(e) {
 err = String(e.message||e);
 }
 const latencyMs = Date.now() - start;
 rows.push({ ...t, gotRisk: got, pass: ok, latencyMs, requiresConfirmation, score, error: err });
 }

 const outDir = path.join(__dirname, 'reports');
 if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
 const stamp = new Date().toISOString().replace(/[:.]/g,'-');
 const jsonPath = path.join(outDir, `eval-${stamp}.json`);
 fs.writeFileSync(jsonPath, JSON.stringify(rows, null, 2), 'utf8');

 const csvHeader = 'id,expectedRisk,gotRisk,pass,latencyMs,requiresConfirmation,score,error\n';
 const csvRows = rows.map(r => [r.id,r.expectedRisk,r.gotRisk,r.pass,r.latencyMs,r.requiresConfirmation,r.score??'',(r.error||'').replace(/,/g,';')].join(',')).join('\n');
 const csvPath = path.join(outDir, `eval-${stamp}.csv`);
 fs.writeFileSync(csvPath, csvHeader + csvRows + '\n', 'utf8');

 const passCount = rows.filter(r=>r.pass).length;
 const p95 = rows.map(r=>r.latencyMs).sort((a,b)=>a-b)[Math.floor(rows.length*0.95)-1] || 0;
 console.log(JSON.stringify({ total: rows.length, passCount, passRate: Number((passCount/rows.length*100).toFixed(1)), p95LatencyMs: p95, jsonPath, csvPath }, null, 2));
}
run();
