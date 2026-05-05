const fastify = require('fastify')({ logger: true });
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const os = require('os');

const DB_PATH = path.join(__dirname, '..', 'data', 'state.json');
const SETTINGS_DEFAULT = {
 installProfile: 'core-only', // core-only | local-ai | openclaw
 aiEnabled: false,
 aiModel: 'phi3:mini',
 aiTier: 'lite',
 openclawEnabled: false
};

function loadState() {
 if (!fs.existsSync(DB_PATH)) {
 return { items: [], actions: [], approvals: [], audit: [], settings: SETTINGS_DEFAULT };
 }
 try { return JSON.parse(fs.readFileSync(DB_PATH, 'utf8')); }
 catch { return { items: [], actions: [], approvals: [], audit: [], settings: SETTINGS_DEFAULT }; }
}
function saveState() { fs.writeFileSync(DB_PATH, JSON.stringify(state, null, 2)); }
const state = loadState();
state.profile = state.profile || { householdSize:1, income:0, location:'', employment:'unknown' };
state.opportunities = state.opportunities || [
 { id:'opp-grant-1', type:'grant', name:'Local Utility Relief', deadline:'2026-06-15', rules:{ maxIncome:50000, locations:['PA','NJ'] } },
 { id:'opp-train-1', type:'training', name:'Workforce Upskill Voucher', deadline:'2026-07-01', rules:{ maxIncome:70000, employment:['unemployed','part-time'] } },
 { id:'opp-job-1', type:'job', name:'Remote Ops Analyst Fellowship', deadline:'2026-06-01', rules:{ locations:['US'], minHousehold:1 } },
 { id:'opp-aid-1', type:'aid', name:'Family Food Support Program', deadline:'2026-05-20', rules:{ maxIncome:45000, minHousehold:2 } }
];
state.opportunityActions = state.opportunityActions || [];
state.baseline = state.baseline || { manualMinutesPerTask: 45, assistedMinutesPerTask: 20 };
state.scenarios = state.scenarios || ['household-admin','job-seeker-pipeline','small-business-compliance'];
state.notifications = state.notifications || [];
state.settings.scheduler = state.settings.scheduler || { enabled:false, intervalSec:60, quietStart:'23:00', quietEnd:'08:00' };

function audit(eventType, detail = {}) {
 state.audit.push({ id: crypto.randomUUID(), ts: new Date().toISOString(), eventType, detail });
 saveState();
}


function detectDocType(text='') {
 const t = text.toLowerCase();
 if (/bill|invoice|payment|past due/.test(t)) return 'bill';
 if (/application|apply|eligibility/.test(t)) return 'application';
 if (/appointment|meeting|visit/.test(t)) return 'appointment';
 if (/legal|court|notice|summons/.test(t)) return 'legal_notice';
 if (/notice|final notice|warning/.test(t)) return 'notice';
 return 'other';
}

function checklistForType(type){
 const m={
 bill:['Verify account and amount','Check due date','Choose pay/dispute plan','Save confirmation'],
 application:['Collect required documents','Complete form fields','Review eligibility notes','Submit and track confirmation'],
 appointment:['Confirm date/time','Prepare required docs','Set reminder 24h before','Record outcome notes'],
 legal_notice:['Read notice carefully','Identify deadline','Prepare response draft','Escalate if required'],
 notice:['Identify action requested','Confirm deadline','Draft response','Archive proof'],
 other:['Clarify task intent','Set deadline','Create action plan']
 };
 return m[type] || m.other;
}

function actionTemplates(type){
 const m={
 bill:['Verify amount and due date','Prepare payment or dispute action'],
 application:['Collect docs checklist','Prepare submission package'],
 appointment:['Confirm attendance details','Prepare required materials'],
 legal_notice:['Draft response and escalation path','Collect supporting records'],
 notice:['Draft response','Escalate if unresolved'],
 other:['Create next-step plan']
 };
 return m[type] || m.other;
}

function extractDeadlines(text) {
 const matches = [...text.matchAll(/\b(\d{4}-\d{2}-\d{2})\b/g)].map(m => m[1]);
 return [...new Set(matches)];
}

function deadlineRisk(item) {
 if (!item.deadline) return 'stable';
 const now = new Date();
 const d = new Date(item.deadline);
 const days = (d - now) / (1000 * 60 * 60 * 24);
 if (days < 0) return 'overdue';
 if (days <= 3) return 'due-soon';
 return 'stable';
}

function actionRiskLevel(title='') {
 const t=String(title).toLowerCase();
 if (/submit|send|pay|sign|file/.test(t)) return 'high';
 if (/prepare|draft|review/.test(t)) return 'medium';
 return 'low';
}

function priorityScore(item) {
 let score = 0;
 const now = new Date();
 if (item.deadline) {
 const d = new Date(item.deadline);
 const days = (d - now) / (1000 * 60 * 60 * 24);
 if (days < 0) score += 100;
 else if (days <= 3) score += 80;
 else if (days <= 7) score += 50;
 else score += 20;
 }
 if (/urgent|final notice|past due|deadline/i.test(item.text || '')) score += 30;
 return score;
}

fastify.get('/', async (req, reply) => reply.type('text/html').send(fs.readFileSync(path.join(__dirname, '..', 'frontend', 'index.html'), 'utf8')));

function scoreOpportunity(profile, opp){
 let score = 100;
 const reasons = [];
 if (opp.rules.maxIncome != null){
 if ((profile.income||0) > opp.rules.maxIncome) { score -= 60; reasons.push(`Income above max (${opp.rules.maxIncome})`); }
 else reasons.push('Income within threshold');
 }
 if (opp.rules.locations){
 const loc = String(profile.location||'').toUpperCase();
 const ok = opp.rules.locations.includes(loc) || opp.rules.locations.includes('US');
 if (!ok){ score -= 30; reasons.push('Location mismatch'); } else reasons.push('Location match');
 }
 if (opp.rules.employment){
 const ok = opp.rules.employment.includes(profile.employment||'unknown');
 if (!ok){ score -= 20; reasons.push('Employment preference mismatch'); } else reasons.push('Employment match');
 }
 if (opp.rules.minHousehold){
 if ((profile.householdSize||1) < opp.rules.minHousehold){ score -= 20; reasons.push('Household below minimum'); } else reasons.push('Household size eligible');
 }
 score = Math.max(0, Math.min(100, score));
 return { score, reasons };
}


function combinedQueue(){
 const now = new Date();
 const items = state.items.map(i=>{
 const pr = priorityScore(i);
 return { id:i.id, source:'paperwork', title:i.text, status:i.status, deadline:i.deadline, score:pr, nextAction:(i.actionTemplates&&i.actionTemplates[0])||'Review item', reason:`Priority ${pr} from deadline/risk` };
 });
 const opps = state.opportunityActions.map(a=>{
 let score = 40;
 if (a.status==='blocked') score += 40;
 if (a.status==='not-started') score += 20;
 if (a.deadline){
 const d = new Date(a.deadline);
 const days = (d-now)/(1000*60*60*24);
 if (days<0) score += 70; else if (days<=3) score += 50; else if (days<=7) score += 25;
 }
 return { id:a.id, source:'opportunity', title:a.name, status:a.status, deadline:a.deadline, score, nextAction:a.nextStep||'Advance status', reason:`Score ${score} from status/deadline` };
 });
 return [...items,...opps].sort((a,b)=>b.score-a.score);
}


function inQuietHours(){
 const q = state.settings.scheduler || {};
 const now = new Date();
 const [sh,sm] = String(q.quietStart||'23:00').split(':').map(Number);
 const [eh,em] = String(q.quietEnd||'08:00').split(':').map(Number);
 const cur = now.getHours()*60+now.getMinutes();
 const s = (sh||0)*60+(sm||0), e=(eh||0)*60+(em||0);
 if (s<e) return cur>=s && cur<e;
 return cur>=s || cur<e;
}

function pushNotification(level, message, kind='reminder'){
 const n = { id: crypto.randomUUID(), ts: new Date().toISOString(), level, message, kind, read:false, snoozedUntil:null };
 state.notifications.push(n);
 audit('notification_created',{id:n.id,level,kind});
}

let schedulerHandle = null;
function runSchedulerTick(){
 if (!state.settings.scheduler?.enabled) return;
 if (inQuietHours()) return;
 const overdue = state.items.filter(i=>deadlineRisk(i)==='overdue' && i.status!=='done').length;
 const soon = state.items.filter(i=>deadlineRisk(i)==='due-soon' && i.status!=='done').length;
 const blocked = state.opportunityActions.filter(a=>a.status==='blocked').length;
 if (overdue>0) pushNotification('high', `You have ${overdue} overdue item(s).`);
 if (soon>0) pushNotification('medium', `${soon} item(s) due soon.`);
 if (blocked>0) pushNotification('medium', `${blocked} blocked opportunity action(s).`,'blocked');
 if (overdue+soon+blocked>=3) {
 audit('autoplan_triggered',{reason:'high_urgency'});
 }
 saveState();
}

function restartScheduler(){
 if (schedulerHandle) clearInterval(schedulerHandle);
 const sec = Math.max(15, Number(state.settings.scheduler?.intervalSec || 60));
 schedulerHandle = setInterval(runSchedulerTick, sec*1000);
}


fastify.get('/api/config/export', async ()=> ({ ok:true, config: state.settings, profile: state.profile }));
fastify.post('/api/config/import', async (req)=>{
 const cfg = req.body?.config || {};
 const profile = req.body?.profile || {};
 state.settings = { ...state.settings, ...cfg };
 state.profile = { ...state.profile, ...profile };
 saveState();
 restartScheduler();
 audit('config_imported',{});
 return { ok:true };
});

fastify.get('/api/version', async ()=> ({ ok:true, version:'v0.2.0-demo' }));

fastify.get('/api/datasets', async ()=>{
 const fs = require('fs'); const path = require('path');
 const dir = path.join(__dirname,'..','datasets');
 if(!fs.existsSync(dir)) return [];
 return fs.readdirSync(dir).filter(x=>x.endsWith('.json'));
});

fastify.post('/api/datasets/save', async (req)=>{
 const fs = require('fs'); const path = require('path');
 const name = String(req.body?.name || 'demo').replace(/[^a-zA-Z0-9_-]/g,'_');
 const dir = path.join(__dirname,'..','datasets'); if(!fs.existsSync(dir)) fs.mkdirSync(dir,{recursive:true});
 const file = path.join(dir, name+'.json');
 fs.writeFileSync(file, JSON.stringify({items:state.items,actions:state.actions,opportunityActions:state.opportunityActions,profile:state.profile}, null, 2));
 audit('dataset_saved',{name});
 return { ok:true, file:name+'.json' };
});

fastify.post('/api/datasets/load', async (req)=>{
 const fs = require('fs'); const path = require('path');
 const name = String(req.body?.name || '');
 const file = path.join(__dirname,'..','datasets',name);
 if(!fs.existsSync(file)) return { ok:false, error:'dataset not found' };
 const d = JSON.parse(fs.readFileSync(file,'utf8'));
 state.items = d.items || [];
 state.actions = d.actions || [];
 state.opportunityActions = d.opportunityActions || [];
 state.profile = d.profile || state.profile;
 saveState();
 audit('dataset_loaded',{name});
 return { ok:true };
});

fastify.get('/api/health', async () => ({ ok: true, app: 'lifeops-copilot' }));


fastify.get('/api/notifications', async ()=> state.notifications.slice(-200).reverse());
fastify.patch('/api/notifications/:id', async (req, reply)=>{
 const n = state.notifications.find(x=>x.id===req.params.id);
 if(!n) return reply.code(404).send({ok:false,error:'notification not found'});
 if (req.body?.read != null) n.read = !!req.body.read;
 if (req.body?.snoozeMinutes) {
 n.snoozedUntil = new Date(Date.now()+Number(req.body.snoozeMinutes)*60000).toISOString();
 }
 saveState();
 return {ok:true,notification:n};
});

fastify.patch('/api/settings/scheduler', async (req)=>{
 state.settings.scheduler = { ...state.settings.scheduler, ...(req.body||{}) };
 saveState();
 restartScheduler();
 audit('scheduler_settings_updated',state.settings.scheduler);
 return { ok:true, scheduler: state.settings.scheduler };
});

fastify.get('/api/settings', async () => state.settings);
fastify.get('/api/model/options', async () => ([
 { id: 'phi3:mini', tier: 'lite', ramGbMin: 4, quality: 'good', speed: 'fast' },
 { id: 'llama3.2:3b', tier: 'balanced', ramGbMin: 8, quality: 'better', speed: 'medium' },
 { id: 'mistral:7b', tier: 'quality', ramGbMin: 16, quality: 'best', speed: 'slow' }
]));
fastify.get('/api/model/check', async (req) => {
 const model = String(req.query?.model || 'phi3:mini');
 const options = {
 'phi3:mini': { ramGbMin: 4 },
 'llama3.2:3b': { ramGbMin: 8 },
 'mistral:7b': { ramGbMin: 16 }
 };
 const totalGb = Math.round((os.totalmem() / (1024 ** 3)) * 10) / 10;
 const need = (options[model] || options['phi3:mini']).ramGbMin;
 const compatible = totalGb >= need;
 return {
 model,
 totalRamGb: totalGb,
 requiredRamGb: need,
 compatible,
 recommendation: compatible ? 'ok' : 'use-lite'
 };
});

fastify.get('/api/profile', async ()=> state.profile);
fastify.patch('/api/profile', async (req)=>{ state.profile = { ...state.profile, ...(req.body||{}) }; saveState(); audit('profile_updated', state.profile); return { ok:true, profile: state.profile }; });

fastify.get('/api/opportunities', async ()=>{
 const scored = state.opportunities.map(o=>({ ...o, ...scoreOpportunity(state.profile,o) })).sort((a,b)=>b.score-a.score);
 return scored;
});

fastify.post('/api/opportunities/:id/add-action', async (req, reply)=>{
 const opp = state.opportunities.find(o=>o.id===req.params.id);
 if(!opp) return reply.code(404).send({ ok:false, error:'opportunity not found' });
 const existing = state.opportunityActions.find(a=>a.opportunityId===opp.id && a.status!=='submitted');
 if(existing) return { ok:true, action: existing, existing:true };
 const action = { id: crypto.randomUUID(), opportunityId: opp.id, name: opp.name, status:'not-started', nextStep:'Review requirements and prepare docs', deadline: opp.deadline, createdAt:new Date().toISOString() };
 state.opportunityActions.push(action); saveState(); audit('opportunity_action_added',{id:action.id,opportunityId:opp.id});
 return { ok:true, action };
});

fastify.get('/api/opportunity-actions', async ()=> state.opportunityActions);
fastify.patch('/api/opportunity-actions/:id', async (req, reply)=>{
 const a = state.opportunityActions.find(x=>x.id===req.params.id);
 if(!a) return reply.code(404).send({ ok:false, error:'action not found' });
 a.status = req.body?.status || a.status;
 if (a.status==='submitted' && !a.completedAt) a.completedAt = new Date().toISOString();
 a.nextStep = req.body?.nextStep ?? a.nextStep;
 saveState(); audit('opportunity_action_updated',{id:a.id,status:a.status});
 return { ok:true, action:a };
});

fastify.patch('/api/settings', async (req) => {
 state.settings = { ...state.settings, ...(req.body || {}) };
 saveState();
 audit('settings_updated', req.body || {});
 return { ok: true, settings: state.settings };
});

fastify.get('/api/items', async () => {
 const out = state.items.map(i => ({ ...i, risk: deadlineRisk(i), priority: priorityScore(i) })).sort((a,b)=>b.priority-a.priority);
 return out;
});


fastify.patch('/api/items/:id/state', async (req, reply) => {
 const item = state.items.find(i => i.id === req.params.id);
 if (!item) return reply.code(404).send({ ok:false, error:'item not found' });
 const next = String(req.body?.status || '');
 const allowed = {
 inbox: ['parsed','blocked'],
 parsed: ['planned','blocked'],
 planned: ['awaiting_approval','blocked'],
 awaiting_approval: ['in_progress','blocked'],
 in_progress: ['done','blocked'],
 blocked: ['planned','in_progress'],
 done: []
 };
 const current = item.status || 'inbox';
 if (!allowed[current] || !allowed[current].includes(next)) {
 return reply.code(400).send({ ok:false, error:`invalid transition ${current} -> ${next}` });
 }
 item.status = next;
 if (next==='done' && !item.completedAt) item.completedAt = new Date().toISOString();
 saveState();
 audit('item_state_changed', { id:item.id, from: current, to: next });
 return { ok:true, item };
});

fastify.get('/api/brief/weekly', async () => {
 const total = state.items.length;
 const overdue = state.items.filter(i => deadlineRisk(i)==='overdue').length;
 const soon = state.items.filter(i => deadlineRisk(i)==='due-soon').length;
 const awaiting = state.actions.filter(a => a.status==='awaiting_approval').length;
 const approved = state.actions.filter(a => a.status==='approved').length;
 const brief = [
 `LifeOps Weekly Brief (${new Date().toISOString().slice(0,10)})`,
 `Items: ${total} | Overdue: ${overdue} | Due Soon: ${soon}`,
 `Actions: awaiting approval=${awaiting}, approved=${approved}`
 ].join('\n');
 audit('weekly_brief_generated', { total, overdue, soon, awaiting, approved });
 return { ok:true, brief };
});

function toCsv(rows, cols){
 const esc=v=>{const s=String(v??''); return /[",\n]/.test(s)?'"'+s.replace(/"/g,'""')+'"':s};
 return [cols.join(','), ...rows.map(r=>cols.map(c=>esc(r[c])).join(','))].join('\n');
}

fastify.get('/api/export/items.csv', async (req, reply)=>{
 const rows = state.items.map(i=>({ ...i, risk: deadlineRisk(i), priority: priorityScore(i) }));
 const csv = toCsv(rows,['id','createdAt','status','deadline','risk','priority','text']);
 reply.header('Content-Type','text/csv');
 return csv;
});
fastify.get('/api/export/actions.csv', async (req, reply)=>{
 const csv = toCsv(state.actions,['id','itemId','title','status','createdAt']);
 reply.header('Content-Type','text/csv');
 return csv;
});
fastify.get('/api/export/audit.csv', async (req, reply)=>{
 const rows = state.audit.map(a=>({id:a.id,ts:a.ts,eventType:a.eventType,detail:JSON.stringify(a.detail||{})}));
 const csv = toCsv(rows,['id','ts','eventType','detail']);
 reply.header('Content-Type','text/csv');
 return csv;
});

fastify.post('/api/inbox/add', async (req, reply) => {
 const text = String(req.body?.text || '').trim();
 if (!text) return reply.code(400).send({ ok: false, error: 'text required' });
 const dls = extractDeadlines(text);
 const docType = detectDocType(text);
 const item = {
 id: crypto.randomUUID(),
 createdAt: new Date().toISOString(),
 type: 'note',
 docType,
 text,
 deadline: dls[0] || null,
 deadlineConfidence: dls.length ? 'explicit' : 'none',
 extractionNotes: dls.length ? 'Found explicit YYYY-MM-DD date in text' : 'No explicit date found',
 checklist: checklistForType(docType),
 actionTemplates: actionTemplates(docType),
 status: 'inbox'
 };
 state.items.push(item);
 saveState();
 audit('inbox_item_added', { id: item.id, deadline: item.deadline });
 return { ok: true, item, extractedDeadlines: dls };
});

fastify.post('/api/actions/propose', async (req, reply) => {
 const { itemId, title } = req.body || {};
 const item = state.items.find(i => i.id === itemId);
 if (!item) return reply.code(404).send({ ok:false, error:'item not found' });
 const action = { id: crypto.randomUUID(), itemId, title: title || 'Follow up', risk: actionRiskLevel(title||'Follow up'), status: 'awaiting_approval', createdAt: new Date().toISOString() };
 state.actions.push(action);
 state.approvals.push({ id: crypto.randomUUID(), actionId: action.id, status: 'pending', createdAt: new Date().toISOString() });
 saveState();
 audit('action_proposed', { actionId: action.id, itemId });
 return { ok:true, action };
});

fastify.post('/api/actions/:id/approve', async (req, reply) => {
 const action = state.actions.find(a => a.id === req.params.id);
 if (!action) return reply.code(404).send({ ok:false, error:'action not found' });
 if (action.risk === 'high') {
 const phrase = String(req.body?.confirmPhrase || '');
 if (phrase !== 'APPROVE HIGH RISK') return reply.code(400).send({ ok:false, error:'High-risk approval requires confirm phrase: APPROVE HIGH RISK' });
 }
 action.status = 'approved';
 const appr = state.approvals.find(a => a.actionId === action.id && a.status === 'pending');
 if (appr) appr.status = 'approved';
 saveState();
 audit('action_approved', { actionId: action.id });
 return { ok:true, action };
});


fastify.get('/api/actions', async ()=> state.actions);
fastify.get('/api/approvals', async ()=> state.approvals);

fastify.post('/api/actions/:id/revert', async (req, reply) => {
 const action = state.actions.find(a => a.id === req.params.id);
 if (!action) return reply.code(404).send({ ok:false, error:'action not found' });
 action.status = 'awaiting_approval';
 state.approvals.push({ id: crypto.randomUUID(), actionId: action.id, status: 'pending', createdAt: new Date().toISOString() });
 saveState();
 audit('action_reverted', { actionId: action.id });
 return { ok:true, action };
});

fastify.get('/api/reminders/preview', async ()=>{
 const now = new Date();
 const rows = state.items.map(i=>{
 if(!i.deadline) return null;
 const d = new Date(i.deadline);
 const days = Math.floor((d-now)/(1000*60*60*24));
 let trigger='none';
 if(days < 0) trigger='overdue-alert';
 else if(days <= 3) trigger='due-soon-alert';
 else if(days <= 7) trigger='upcoming-reminder';
 return { itemId:i.id, deadline:i.deadline, daysRemaining:days, trigger, status:i.status };
 }).filter(Boolean);
 return rows.sort((a,b)=>a.daysRemaining-b.daysRemaining);
});


fastify.post('/api/demo/seed', async ()=>{
 const samples = [
 { text: 'Utility bill final notice due 2026-05-08', deadline: '2026-05-08', status: 'planned' },
 { text: 'Submit aid application by 2026-05-06', deadline: '2026-05-06', status: 'awaiting_approval' },
 { text: 'Renew license before 2026-05-20', deadline: '2026-05-20', status: 'inbox' }
 ];
 let added = 0;
 for (const x of samples) {
 const exists = state.items.some(i => i.text === x.text && i.deadline === x.deadline);
 if (exists) continue;
 const docType=detectDocType(x.text); state.items.push({ id: crypto.randomUUID(), createdAt: new Date().toISOString(), type:'note', docType, text:x.text, deadline:x.deadline, deadlineConfidence:'explicit', extractionNotes:'Seeded demo deadline', checklist: checklistForType(docType), actionTemplates: actionTemplates(docType), status:x.status });
 added += 1;
 }
 const hasPendingDemo = state.actions.some(a => a.title==='Prepare docs and submit' && a.status==='awaiting_approval');
 const target = state.items.find(i=>i.status==='awaiting_approval');
 if (target && !hasPendingDemo) {
 const action = { id: crypto.randomUUID(), itemId: target.id, title:'Prepare docs and submit', risk:'high', status:'awaiting_approval', createdAt:new Date().toISOString() };
 state.actions.push(action);
 state.approvals.push({ id: crypto.randomUUID(), actionId: action.id, status:'pending', createdAt:new Date().toISOString() });
 }
 saveState();
 audit('demo_seed_loaded', { added });
 return { ok:true, added };
});

fastify.post('/api/demo/reset', async ()=>{
 state.items = [];
 state.actions = [];
 state.approvals = [];
 saveState();
 audit('demo_reset', {});
 return { ok:true };
});


fastify.get('/api/queue/today', async ()=> combinedQueue());
fastify.get('/api/plan/day', async ()=>{
 const q = combinedQueue().slice(0,10);
 const lines = q.map((x,i)=>`${i+1}. [${x.source}] ${x.title} -> ${x.nextAction} (${x.reason})`);
 const planText = ['LifeOps Plan My Day', ...lines].join('\n');
 audit('day_plan_generated',{count:q.length});
 return { ok:true, plan:q, text:planText };
});
fastify.get('/api/digest/daily', async ()=>{
 const overdue = state.items.filter(i=>deadlineRisk(i)==='overdue').length;
 const soon = state.items.filter(i=>deadlineRisk(i)==='due-soon').length;
 const blocked = state.opportunityActions.filter(a=>a.status==='blocked').length;
 const top3 = combinedQueue().slice(0,3);
 return { ok:true, overdue, dueSoon:soon, blocked, top3 };
});
fastify.get('/api/metrics/local', async ()=>{
 const completedItems = state.items.filter(i=>i.status==='done').length;
 const completedOpp = state.opportunityActions.filter(a=>a.status==='submitted').length;
 const overdue = state.items.filter(i=>deadlineRisk(i)==='overdue').length;
 return { ok:true, completedItems, completedOpportunityActions: completedOpp, overdueOpenItems: overdue, totalAuditEvents: state.audit.length };
});


fastify.get('/api/confirmations/high-risk', async ()=> state.actions.filter(a=>a.risk==='high' && a.status==='awaiting_approval'));

fastify.get('/api/timeline', async ()=> state.audit.slice(-300).reverse());

fastify.get('/api/export/bundle', async ()=>{
 const queue = combinedQueue();
 const digest = {
 overdue: state.items.filter(i=>deadlineRisk(i)==='overdue').length,
 dueSoon: state.items.filter(i=>deadlineRisk(i)==='due-soon').length,
 blocked: state.opportunityActions.filter(a=>a.status==='blocked').length
 };
 const metrics = {
 completedItems: state.items.filter(i=>i.status==='done').length,
 completedOpportunityActions: state.opportunityActions.filter(a=>a.status==='submitted').length,
 overdueOpenItems: state.items.filter(i=>deadlineRisk(i)==='overdue').length,
 totalAuditEvents: state.audit.length
 };
 return { ok:true, generatedAt:new Date().toISOString(), queue, digest, metrics, auditTail: state.audit.slice(-100) };
});

fastify.patch('/api/settings/mode', async (req)=>{
 const mode = req.body?.mode === 'demo' ? 'demo' : 'real';
 state.settings.mode = mode;
 saveState();
 audit('mode_switched',{mode});
 return { ok:true, mode };
});


fastify.get('/api/outcomes', async ()=>{
 const doneItems = state.items.filter(i=>i.status==='done');
 const submittedOpp = state.opportunityActions.filter(a=>a.status==='submitted');
 const avgItemMinutes = doneItems.length ? Math.round(doneItems.map(i=>{
 const c = new Date(i.createdAt).getTime();
 const d = new Date(i.completedAt||i.createdAt).getTime();
 return (d-c)/60000;
 }).reduce((x,y)=>x+y,0)/doneItems.length) : 0;
 const overdueRescued = doneItems.filter(i=>i.deadline && new Date(i.completedAt||i.createdAt) > new Date(i.deadline)).length;
 return { ok:true, completedItems: doneItems.length, submittedOpportunities: submittedOpp.length, avgMinutesToCompleteItem: avgItemMinutes, overdueRescued };
});

fastify.get('/api/impact', async ()=>{
 const completed = state.items.filter(i=>i.status==='done').length + state.opportunityActions.filter(a=>a.status==='submitted').length;
 const baseline = state.baseline.manualMinutesPerTask * completed;
 const assisted = state.baseline.assistedMinutesPerTask * completed;
 return { ok:true, completedTasks: completed, manualMinutesEstimate: baseline, assistedMinutesEstimate: assisted, minutesSavedEstimate: Math.max(0, baseline-assisted), assumptions: state.baseline };
});

fastify.patch('/api/impact/assumptions', async (req)=>{
 state.baseline = { ...state.baseline, ...(req.body||{}) }; saveState(); audit('impact_assumptions_updated',state.baseline); return { ok:true, baseline: state.baseline };
});

fastify.get('/api/case-study/md', async ()=>{
 const outcomes = {
 completedItems: state.items.filter(i=>i.status==='done').length,
 submittedOpportunities: state.opportunityActions.filter(a=>a.status==='submitted').length,
 overdueOpen: state.items.filter(i=>deadlineRisk(i)==='overdue').length
 };
 const text = `# LifeOps Case Study

## Problem
Manual life/work admin is fragmented and deadline-prone.

## Workflow
Ingest -> classify -> prioritize -> approve -> execute -> track.

## Outcomes
- Completed items: ${outcomes.completedItems}
- Submitted opportunities: ${outcomes.submittedOpportunities}
- Overdue open items: ${outcomes.overdueOpen}

## Notes
Generated from current local state.`;
 return { ok:true, markdown: text };
});

fastify.get('/api/scenarios', async ()=> state.scenarios);
fastify.post('/api/scenarios/load', async (req)=>{
 const name = req.body?.name || 'household-admin';
 if (name==='household-admin') {
 state.items.push({id:crypto.randomUUID(),createdAt:new Date().toISOString(),type:'note',docType:'bill',text:'Internet bill due 2026-05-10',deadline:'2026-05-10',deadlineConfidence:'explicit',extractionNotes:'scenario',checklist:checklistForType('bill'),actionTemplates:actionTemplates('bill'),status:'planned'});
 }
 if (name==='job-seeker-pipeline') {
 state.opportunityActions.push({id:crypto.randomUUID(),opportunityId:'opp-job-1',name:'Remote Ops Analyst Fellowship',status:'not-started',nextStep:'Tailor resume',deadline:'2026-06-01',createdAt:new Date().toISOString()});
 }
 if (name==='small-business-compliance') {
 state.items.push({id:crypto.randomUUID(),createdAt:new Date().toISOString(),type:'note',docType:'notice',text:'Quarterly tax filing notice due 2026-05-18',deadline:'2026-05-18',deadlineConfidence:'explicit',extractionNotes:'scenario',checklist:checklistForType('notice'),actionTemplates:actionTemplates('notice'),status:'inbox'});
 }
 saveState(); audit('scenario_loaded',{name});
 return { ok:true, name };
});

fastify.get('/api/audit', async ()=> state.audit.slice(-200).reverse());

fastify.listen({ port: 3360, host: '0.0.0.0' });
