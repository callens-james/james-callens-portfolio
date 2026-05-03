const Fastify = require('fastify');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

const app = Fastify({ logger: false });
app.register(require('@fastify/static'), { root: path.join(__dirname,'public'), prefix:'/' });

const reportsDir = path.join(__dirname, 'reports');

function listReports() {
  if (!fs.existsSync(reportsDir)) return [];
  return fs.readdirSync(reportsDir).filter(f=>f.endsWith('.json')).sort().reverse();
}

app.get('/api/reports', async ()=>({ reports: listReports() }));

app.get('/api/report/:name', async (req, reply)=>{
  const p = path.join(reportsDir, req.params.name);
  if (!fs.existsSync(p)) return reply.code(404).send({ error:'Not found' });
  return JSON.parse(fs.readFileSync(p,'utf8'));
});

app.post('/api/run', async ()=>{
  return new Promise((resolve, reject)=>{
    const proc = spawn(process.execPath, ['runner.js'], { cwd: __dirname });
    let out=''; let err='';
    proc.stdout.on('data', d=> out += d.toString());
    proc.stderr.on('data', d=> err += d.toString());
    proc.on('close', code=>{
      if (code!==0) return reject(new Error(err || `runner exited ${code}`));
      try { resolve(JSON.parse(out)); }
      catch { resolve({ raw: out }); }
    });
  });
});

app.listen({ port: 3346, host:'0.0.0.0' }).then(()=>console.log('Eval Harness on http://localhost:3346'));
