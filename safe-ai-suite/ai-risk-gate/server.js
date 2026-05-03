const Fastify = require('fastify');
const fs = require('fs');
const path = require('path');

const app = Fastify({ logger: false });
const policy = JSON.parse(fs.readFileSync(path.join(__dirname, 'config/policy.json'), 'utf8'));
const logPath = path.join(__dirname, 'logs', 'decisions.jsonl');

app.register(require('@fastify/static'), {
  root: path.join(__dirname, 'public'),
  prefix: '/'
});

function classifyRisk({ task='', tool='', action='' }) {
  const t = `${task} ${action}`.toLowerCase();
  const reasons = [];
  let score = 0;

  if (policy.highRiskTools.includes(tool)) { score += 60; reasons.push(`high-risk tool: ${tool}`); }
  if (policy.mediumRiskTools.includes(tool)) { score += 30; reasons.push(`medium-risk tool: ${tool}`); }

  for (const k of policy.highRiskKeywords) {
    if (t.includes(k)) { score += 35; reasons.push(`high-risk keyword: ${k}`); }
  }
  for (const k of policy.mediumRiskKeywords) {
    if (t.includes(k)) { score += 15; reasons.push(`medium-risk keyword: ${k}`); }
  }

  if (policy.alwaysConfirmActions.includes(action)) {
    score = Math.max(score, 75);
    reasons.push(`always-confirm action: ${action}`);
  }

  const riskLevel = score >= 75 ? 'high' : score >= 35 ? 'medium' : 'low';
  const requiresConfirmation = riskLevel !== 'low';

  return { riskLevel, score, reasons, requiresConfirmation };
}

function audit(entry) {
  const line = JSON.stringify({ ts: new Date().toISOString(), ...entry }) + '\n';
  fs.appendFileSync(logPath, line, 'utf8');
}

app.post('/api/evaluate', async (req, reply) => {
  const input = req.body || {};
  const decision = classifyRisk(input);
  audit({ input, decision });
  return { input, decision };
});

app.get('/api/health', async () => ({ ok: true }));

app.listen({ port: 3344, host: '0.0.0.0' }).then(() => {
  console.log('AI Risk Gate listening on http://localhost:3344');
});
