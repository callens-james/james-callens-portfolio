const Fastify = require('fastify');
const path = require('path');
const fs = require('fs');

const app = Fastify({ logger: false });
const LOG_PATH = process.env.RISK_LOG_PATH || '/home/james/openclaw-workspace/Safe AI/projects/ai-risk-gate/logs/decisions.jsonl';

app.register(require('@fastify/static'), {
  root: path.join(__dirname, 'public'),
  prefix: '/'
});

function loadEvents(limit=300){
  if(!fs.existsSync(LOG_PATH)) return [];
  const lines=fs.readFileSync(LOG_PATH,'utf8').trim().split('\n').filter(Boolean);
  const parsed=[];
  for(const ln of lines.slice(-limit)){
    try{ parsed.push(JSON.parse(ln)); }catch{}
  }
  return parsed.reverse();
}

app.get('/api/events', async (req)=>{
  const limit = Math.min(Number(req.query.limit||200), 1000);
  const risk = String(req.query.risk||'').toLowerCase();
  const tool = String(req.query.tool||'').toLowerCase();
  let events=loadEvents(limit);
  if(risk) events=events.filter(e=>String(e?.decision?.riskLevel||'').toLowerCase()===risk);
  if(tool) events=events.filter(e=>String(e?.input?.tool||'').toLowerCase().includes(tool));
  return { ok:true, count:events.length, events };
});

app.get('/api/summary', async ()=>{
  const events=loadEvents(1000);
  const summary={total:events.length, low:0, medium:0, high:0, confirm:0};
  for(const e of events){
    const r=e?.decision?.riskLevel;
    if(r==='low') summary.low++;
    if(r==='medium') summary.medium++;
    if(r==='high') summary.high++;
    if(e?.decision?.requiresConfirmation) summary.confirm++;
  }
  return { ok:true, summary };
});

app.listen({ port: 3345, host:'0.0.0.0' }).then(()=>console.log('Timeline Viewer on http://localhost:3345'));
