const Fastify = require('fastify');
const fs = require('fs');
const path = require('path');

const app = Fastify({ logger: false });
const policy = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'config', 'policy.json'), 'utf8'));
const auditPath = path.join(__dirname, '..', 'logs', 'audit.jsonl');

function logAudit(event) {
  const line = JSON.stringify({ ts: new Date().toISOString(), ...event }) + '\n';
  fs.appendFileSync(auditPath, line, 'utf8');
}

function decide(request) {
  const action = String(request.action || '').toLowerCase();
  if (policy.blockedActions.includes(action)) {
    return { allowed: false, reason: 'blocked-action', requiresConfirmation: false };
  }
  const risky = /(delete|restart|deploy|rotate|install|migrate|network|token|password)/i.test(request.task || '') || /(delete|restart-service|deploy)/i.test(action);
  const requiresConfirmation = risky;
  return { allowed: true, reason: risky ? 'risky-confirm-required' : 'low-risk', requiresConfirmation };
}

app.get('/health', async () => ({ ok: true, policy }));

app.post('/guard/evaluate', async (req) => {
  const input = req.body || {};
  const decision = decide(input);
  logAudit({ type: 'guard-evaluate', input, decision });
  return { input, decision };
});

app.post('/guard/execute', async (req, reply) => {
  const input = req.body || {};
  const confirmation = String(req.headers['x-confirm'] || '').toLowerCase();
  const decision = decide(input);

  if (!decision.allowed) {
    logAudit({ type: 'execute-blocked', input, decision });
    return reply.code(403).send({ ok: false, error: decision.reason, decision });
  }

  if (decision.requiresConfirmation && confirmation !== 'yes') {
    logAudit({ type: 'execute-needs-confirm', input, decision });
    return reply.code(409).send({ ok: false, error: 'confirmation-required', decision });
  }

  // Template: replace this block with real tool execution handlers.
  const result = { simulated: true, message: `Executed action '${input.action || 'n/a'}'` };
  logAudit({ type: 'execute-ok', input, decision, result });
  return { ok: true, decision, result };
});

app.listen({ port: 3347, host: '0.0.0.0' }).then(() => {
  console.log('Safe Automation Template on http://localhost:3347');
});
