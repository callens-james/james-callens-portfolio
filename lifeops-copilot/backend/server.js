const fastify = require('fastify')({ logger: true });
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const os = require('os');

const BACKUP_DIR = path.join(__dirname, '..', 'data', 'backups');
const DB_PATH = path.join(__dirname, '..', 'data', 'state.json');
const SETTINGS_DEFAULT = {
  installProfile: 'core-only', // core-only | local-ai | openclaw
  aiEnabled: false,
  aiModel: 'phi3:mini',
  aiTier: 'lite',
  openclawEnabled: false
};

function migrateState(st){
  st.stateVersion = st.stateVersion || '0.3.0';
  st.items = st.items || []; st.actions = st.actions || []; st.approvals = st.approvals || []; st.audit = st.audit || [];
  st.settings = { ...SETTINGS_DEFAULT, ...(st.settings||{}) };
  return st;
}

function loadState() {
  if (!fs.existsSync(DB_PATH)) {
    return migrateState({ items: [], actions: [], approvals: [], audit: [], settings: SETTINGS_DEFAULT });
  }
  try { return migrateState(JSON.parse(fs.readFileSync(DB_PATH, 'utf8'))); }
  catch { return migrateState({ items: [], actions: [], approvals: [], audit: [], settings: SETTINGS_DEFAULT }); }
}
function ensureBackupDir(){ if(!fs.existsSync(BACKUP_DIR)) fs.mkdirSync(BACKUP_DIR,{recursive:true}); }
function saveBackup(){
  ensureBackupDir();
  const ts=new Date().toISOString().replace(/[:.]/g,'-');
  fs.writeFileSync(path.join(BACKUP_DIR,`state-${ts}.json`), JSON.stringify(state,null,2));
}
function saveState() {
  fs.writeFileSync(DB_PATH, JSON.stringify(state, null, 2));
  saveCounter += 1;
  if (saveCounter % 20 === 0) saveBackup();
}
const state = loadState();
let saveCounter = 0;
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
state.careerApps = state.careerApps || [];
state.smbInvoices = state.smbInvoices || [];
state.smbCompliance = state.smbCompliance || [];
state.smbVendors = state.smbVendors || [];
state.healthCases = state.healthCases || [];
state.modules = state.modules || { career:true, smb:true, health:true };
state.security = state.security || { lockEnabled:false, passcodeHash:null, redactionDefault:true };
state.users = state.users || [{id:'u-owner',name:'Owner',role:'owner'},{id:'u-member',name:'Member',role:'member'},{id:'u-viewer',name:'Viewer',role:'viewer'}];
state.userNotifications = state.userNotifications || {};
state.auditPrevHash = state.auditPrevHash || null;

function audit(eventType, detail = {}) {
  const payload = JSON.stringify({ts:new Date().toISOString(),eventType,detail,prev:state.auditPrevHash||''});
  const h = crypto.createHash('sha256').update(payload).digest('hex');
  state.auditPrevHash = h;
  state.audit.push({ id: crypto.randomUUID(), ts: new Date().toISOString(), eventType, detail, hash:h, prevHash: state.auditPrevHash });
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
  
  const careers = state.modules?.career ? state.careerApps.map(c=>({
    id:c.id, source:'career', title:`${c.company} - ${c.role}`, status:c.status, deadline:c.followUpAt, score:(c.fitScore||50) + (c.status==='target'?20:0), nextAction:'Follow up or update status', reason:`Fit ${c.fitScore||50}`
  })) : [];
  const smb = state.modules?.smb ? [
    ...state.smbInvoices.filter(i=>i.status!=='paid').map(i=>({id:i.id,source:'smb',title:`Invoice ${i.client} $${i.amount}`,status:i.status,deadline:i.dueDate,score:60,nextAction:'Follow up on invoice',reason:'Open invoice'})),
    ...state.smbCompliance.filter(c=>c.status!=='done').map(c=>({id:c.id,source:'smb',title:`Compliance ${c.item}`,status:c.status,deadline:c.dueDate,score:55,nextAction:'Complete compliance item',reason:'Open compliance'}))
  ] : [];
  const health = state.modules?.health ? state.healthCases.filter(h=>h.status!=='done').map(h=>({id:h.id,source:'health',title:`${h.type} - ${h.payer}`,status:h.status,deadline:h.deadline,score:h.priority==='high'?90:65,nextAction:'Advance case and submit docs',reason:`Priority ${h.priority}`})) : [];
  return [...items,...opps,...careers,...smb,...health].sort((a,b)=>b.score-a.score);

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


fastify.get('/api/backups', async ()=>{ ensureBackupDir(); return fs.readdirSync(BACKUP_DIR).filter(x=>x.endsWith('.json')).sort().reverse(); });
fastify.post('/api/backups/restore', async (req)=>{ const user=currentUser(req); if(!can(user,'all')) return {ok:false,error:'permission denied'}; ensureBackupDir(); const name=String(req.body?.name||''); const f=path.join(BACKUP_DIR,name); if(!fs.existsSync(f)) return {ok:false,error:'backup not found'}; const loaded = migrateState(JSON.parse(fs.readFileSync(f,'utf8'))); Object.keys(state).forEach(k=>delete state[k]); Object.assign(state, loaded); saveState(); audit('backup_restored',{name}); return {ok:true}; });

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


function careerFitScore(app){
  let score = 50;
  const role = String(app.role||'').toLowerCase();
  const notes = String(app.notes||'').toLowerCase();
  if (/analyst|operations|data/.test(role)) score += 25;
  if (/remote/.test(role+ ' ' + notes)) score += 15;
  if (/ai|automation/.test(role+ ' ' + notes)) score += 10;
  return Math.max(0, Math.min(100, score));
}


fastify.get('/api/career/analytics', async ()=>{
  const rows = state.careerApps;
  const total = rows.length;
  const bySource = {};
  const byRole = {};
  let responded = 0;
  const respDays = [];
  for (const r of rows){
    bySource[r.source||'unknown'] = (bySource[r.source||'unknown']||0)+1;
    byRole[r.role||'unknown'] = (byRole[r.role||'unknown']||0)+1;
    if (['interview','offer','rejected'].includes(r.status)) responded += 1;
    if (r.appliedAt && r.status==='interview') {
      const d1 = new Date(r.appliedAt).getTime();
      const d2 = new Date().getTime();
      if (Number.isFinite(d1)) respDays.push((d2-d1)/(1000*60*60*24));
    }
  }
  const responseRate = total ? Math.round((responded/total)*1000)/10 : 0;
  const medianResponseDays = respDays.length ? respDays.sort((a,b)=>a-b)[Math.floor(respDays.length/2)].toFixed(1) : 'n/a';
  return { ok:true, total, responded, responseRate, bySource, byRole, medianResponseDays };
});

fastify.get('/api/career/report/weekly.md', async ()=>{
  const a = await (async()=>{
    const rows = state.careerApps;
    const total = rows.length;
    const responded = rows.filter(r=>['interview','offer','rejected'].includes(r.status)).length;
    const rate = total ? ((responded/total)*100).toFixed(1) : '0.0';
    const top = rows.slice(-10).reverse().map(r=>`- ${r.company} | ${r.role} | ${r.status} | fit ${r.fitScore}`).join('\n');
    return { total, responded, rate, top };
  })();
  const md = `# Weekly Career Report\n\n- Total tracked applications: ${a.total}\n- Responded outcomes: ${a.responded}\n- Response rate: ${a.rate}%\n\n## Latest Applications\n${a.top||'- none'}`;
  return { ok:true, markdown: md };
});

fastify.get('/api/career/report/weekly.csv', async (req, reply)=>{
  const rows = state.careerApps;
  const cols = ['id','company','role','source','status','appliedAt','followUpAt','fitScore'];
  const esc=v=>{const s=String(v??''); return /[",\n]/.test(s)?'"'+s.replace(/"/g,'""')+'"':s};
  const csv = [cols.join(','), ...rows.map(r=>cols.map(c=>esc(r[c])).join(','))].join('\n');
  reply.header('Content-Type','text/csv');
  return csv;
});

fastify.get('/api/career/interview-prep/:id', async (req, reply)=>{
  const r = state.careerApps.find(x=>x.id===req.params.id);
  if(!r) return reply.code(404).send({ok:false,error:'app not found'});
  const md = `# Interview Prep: ${r.company} — ${r.role}\n\n## Positioning\n- Emphasize local-first automation and safety controls\n- Show metrics-driven impact\n\n## Company Questions\n- How does this role define success in 90 days?\n- What operational bottlenecks are highest priority?\n\n## Story Points\n- Built LifeOps Copilot modules for paperwork + opportunities + trust layer\n- Implemented explainable scoring, approvals, rollback, and auditability`;
  return { ok:true, markdown: md };
});



fastify.get('/api/healthcases', async ()=> state.healthCases);
fastify.post('/api/healthcases', async (req)=>{
  const b=req.body||{};
  const c={
    id: crypto.randomUUID(),
    type: b.type || 'claim',
    payer: b.payer || 'Unknown Payer',
    status: b.status || 'open',
    deadline: b.deadline || null,
    priority: b.priority || 'medium',
    notes: b.notes || '',
    checklist: b.checklist || ['Collect required documents','Verify member/provider IDs','Submit packet','Track response'],
    createdAt: new Date().toISOString()
  };
  state.healthCases.push(c);
  if (c.priority==='high') pushNotification('high', `High-priority health case: ${c.type} (${c.payer})`, 'health');
  saveState(); audit('health_case_added',{id:c.id,type:c.type});
  return {ok:true,healthCase:c};
});
fastify.patch('/api/healthcases/:id', async (req, reply)=>{
  const c=state.healthCases.find(x=>x.id===req.params.id);
  if(!c) return reply.code(404).send({ok:false,error:'health case not found'});
  Object.assign(c, req.body||{});
  saveState(); audit('health_case_updated',{id:c.id,status:c.status});
  return {ok:true,healthCase:c};
});

fastify.get('/api/healthcases/digest', async ()=>{
  const open = state.healthCases.filter(c=>c.status!=='done').length;
  const high = state.healthCases.filter(c=>c.priority==='high' && c.status!=='done').length;
  const overdue = state.healthCases.filter(c=>c.deadline && new Date(c.deadline)<new Date() && c.status!=='done').length;
  const text = `Health Digest\nOpen cases: ${open}\nHigh-priority open: ${high}\nOverdue: ${overdue}`;
  return {ok:true,text,open,high,overdue};
});

fastify.get('/api/smb/invoices', async ()=> state.smbInvoices);
fastify.post('/api/smb/invoices', async (req)=>{
  const b=req.body||{};
  const inv={ id:crypto.randomUUID(), client:b.client||'Unknown', amount:Number(b.amount||0), dueDate:b.dueDate||null, status:b.status||'open', lastFollowUpAt:b.lastFollowUpAt||null, risk:b.risk||'medium', createdAt:new Date().toISOString() };
  state.smbInvoices.push(inv); saveState(); audit('smb_invoice_added',{id:inv.id});
  return {ok:true,invoice:inv};
});
fastify.patch('/api/smb/invoices/:id', async (req,reply)=>{
  const x=state.smbInvoices.find(i=>i.id===req.params.id); if(!x) return reply.code(404).send({ok:false,error:'invoice not found'});
  Object.assign(x, req.body||{}); saveState(); audit('smb_invoice_updated',{id:x.id,status:x.status}); return {ok:true,invoice:x};
});

fastify.get('/api/smb/compliance', async ()=> state.smbCompliance);
fastify.post('/api/smb/compliance', async (req)=>{
  const b=req.body||{};
  const c={ id:crypto.randomUUID(), item:b.item||'Compliance Item', dueDate:b.dueDate||null, status:b.status||'open', owner:b.owner||'owner', createdAt:new Date().toISOString() };
  state.smbCompliance.push(c); saveState(); audit('smb_compliance_added',{id:c.id}); return {ok:true,item:c};
});
fastify.patch('/api/smb/compliance/:id', async (req,reply)=>{
  const c=state.smbCompliance.find(i=>i.id===req.params.id); if(!c) return reply.code(404).send({ok:false,error:'compliance not found'});
  Object.assign(c, req.body||{}); saveState(); audit('smb_compliance_updated',{id:c.id,status:c.status}); return {ok:true,item:c};
});

fastify.get('/api/smb/vendors', async ()=> state.smbVendors);
fastify.post('/api/smb/vendors', async (req)=>{
  const b=req.body||{};
  const v={ id:crypto.randomUUID(), name:b.name||'Vendor', risk:b.risk||'low', note:b.note||'', createdAt:new Date().toISOString() };
  state.smbVendors.push(v); saveState(); audit('smb_vendor_added',{id:v.id,risk:v.risk});
  if (v.risk==='high') pushNotification('high', `High-risk vendor flagged: ${v.name}`, 'vendor-risk');
  return {ok:true,vendor:v};
});

fastify.get('/api/smb/weekly-brief', async ()=>{
  const openInvoices = state.smbInvoices.filter(i=>i.status!=='paid').length;
  const overdueInvoices = state.smbInvoices.filter(i=>i.dueDate && new Date(i.dueDate)<new Date() && i.status!=='paid').length;
  const openCompliance = state.smbCompliance.filter(c=>c.status!=='done').length;
  const highRiskVendors = state.smbVendors.filter(v=>v.risk==='high').length;
  const text = `SMB Weekly Brief\nOpen invoices: ${openInvoices} (overdue: ${overdueInvoices})\nOpen compliance items: ${openCompliance}\nHigh-risk vendors: ${highRiskVendors}`;
  return {ok:true,text};
});

fastify.get('/api/career/apps', async ()=> state.careerApps);
fastify.post('/api/career/apps', async (req)=>{
  const b = req.body||{};
  const app = {
    id: crypto.randomUUID(),
    company: b.company || 'Unknown',
    role: b.role || 'Unknown Role',
    source: b.source || 'manual',
    status: b.status || 'target',
    appliedAt: b.appliedAt || null,
    followUpAt: b.followUpAt || null,
    notes: b.notes || '',
    fitScore: 0,
    createdAt: new Date().toISOString()
  };
  app.fitScore = careerFitScore(app);
  state.careerApps.push(app);
  if (app.followUpAt) pushNotification('medium', `Career follow-up due for ${app.company} (${app.role})`, 'career-followup');
  saveState(); audit('career_app_added',{id:app.id});
  return { ok:true, app };
});
fastify.patch('/api/career/apps/:id', async (req, reply)=>{
  const a = state.careerApps.find(x=>x.id===req.params.id);
  if(!a) return reply.code(404).send({ok:false,error:'app not found'});
  Object.assign(a, req.body||{});
  a.fitScore = careerFitScore(a);
  saveState(); audit('career_app_updated',{id:a.id,status:a.status});
  return { ok:true, app:a };
});
fastify.delete('/api/career/apps/:id', async (req)=>{
  state.careerApps = state.careerApps.filter(x=>x.id!==req.params.id);
  saveState(); audit('career_app_deleted',{id:req.params.id});
  return { ok:true };
});


fastify.get('/api/modules', async ()=> state.modules);
fastify.patch('/api/modules', async (req)=>{ const user=currentUser(req); if(!can(user,'all')) return {ok:false,error:'permission denied'};
  state.modules = { ...state.modules, ...(req.body||{}) };
  saveState(); audit('modules_updated', state.modules);
  return { ok:true, modules: state.modules };
});


fastify.get('/api/v2/case-studies', async ()=>{
  const docs = {
    career: {
      title: 'Career Copilot Case Study',
      summary: `Tracked applications: ${state.careerApps.length}; response rate insights available in analytics.`
    },
    smb: {
      title: 'SMB Console Case Study',
      summary: `Open invoices: ${state.smbInvoices.filter(i=>i.status!=='paid').length}; open compliance: ${state.smbCompliance.filter(c=>c.status!=='done').length}.`
    },
    health: {
      title: 'Health Bureaucracy Case Study',
      summary: `Open health cases: ${state.healthCases.filter(c=>c.status!=='done').length}; high-priority open: ${state.healthCases.filter(c=>c.priority==='high'&&c.status!=='done').length}.`
    }
  };
  return { ok:true, docs };
});

fastify.post('/api/v2/demo/activate', async ()=>{
  state.settings.mode = 'demo';
  // ensure minimal demo records for each module
  if (state.careerApps.length===0) state.careerApps.push({id:crypto.randomUUID(),company:'DemoCo',role:'Operations Analyst',source:'demo',status:'target',appliedAt:null,followUpAt:'2026-05-12',notes:'remote',fitScore:85,createdAt:new Date().toISOString()});
  if (state.smbInvoices.length===0) state.smbInvoices.push({id:crypto.randomUUID(),client:'Acme LLC',amount:1200,dueDate:'2026-05-10',status:'open',risk:'medium',createdAt:new Date().toISOString()});
  if (state.healthCases.length===0) state.healthCases.push({id:crypto.randomUUID(),type:'claim',payer:'Demo Health',status:'open',deadline:'2026-05-09',priority:'high',notes:'demo',checklist:['Collect docs','Submit claim'],createdAt:new Date().toISOString()});
  saveState();
  audit('v2_demo_activated',{});
  return { ok:true };
});

fastify.get('/api/v2/release-readiness', async ()=>{
  const checks = {
    health: true,
    queue: Array.isArray(combinedQueue()),
    modulesConfigured: !!state.modules,
    careerModule: Array.isArray(state.careerApps),
    smbModule: Array.isArray(state.smbInvoices) && Array.isArray(state.smbCompliance),
    healthModule: Array.isArray(state.healthCases),
    exports: true
  };
  const passed = Object.values(checks).every(Boolean);
  return { ok:true, passed, checks, version:'v0.3.0-v2-demo' };
});


fastify.get('/api/security', async ()=> ({ ...state.security, passcodeHash: state.security.passcodeHash ? 'set' : null }));
fastify.patch('/api/security', async (req)=>{
  const b=req.body||{};
  if (typeof b.lockEnabled==='boolean') state.security.lockEnabled=b.lockEnabled;
  if (b.passcode) state.security.passcodeHash = crypto.createHash('sha256').update(String(b.passcode)).digest('hex');
  if (typeof b.redactionDefault==='boolean') state.security.redactionDefault=b.redactionDefault;
  saveState(); audit('security_updated',{lockEnabled:state.security.lockEnabled,redactionDefault:state.security.redactionDefault});
  return { ok:true };
});
fastify.post('/api/security/unlock', async (req)=>{
  if(!state.security.lockEnabled) return {ok:true, unlocked:true};
  const pass = String(req.body?.passcode||'');
  const hash = crypto.createHash('sha256').update(pass).digest('hex');
  return { ok:true, unlocked: hash===state.security.passcodeHash };
});


fastify.get('/api/installer/profiles', async ()=>{
  const fp = path.join(__dirname,'..','installer','INSTALL_PROFILES.json');
  if (!fs.existsSync(fp)) return { profiles: [] };
  return JSON.parse(fs.readFileSync(fp,'utf8'));
});

fastify.post('/api/installer/apply-profile', async (req)=>{
  const id = String(req.body?.profileId || 'core-only');
  const map = {
    'core-only': { installProfile:'core-only', aiEnabled:false, openclawEnabled:false },
    'local-ai': { installProfile:'local-ai', aiEnabled:true, openclawEnabled:false },
    'openclaw': { installProfile:'openclaw', aiEnabled:false, openclawEnabled:true }
  };
  state.settings = { ...state.settings, ...(map[id]||map['core-only']) };
  saveState();
  audit('installer_profile_applied',{profileId:id});
  return { ok:true, settings: state.settings };
});


function stateChecksum(){
  return crypto.createHash('sha256').update(JSON.stringify(state)).digest('hex');
}

fastify.get('/api/data/export-package', async (req)=>{
  const redacted = req.query?.redacted === '1';
  const includeAudit = req.query?.audit !== '0';
  const includeNotes = req.query?.notes !== '0';
  const clone = JSON.parse(JSON.stringify(state));
  if (redacted) {
    const mask=(v)=>typeof v==='string'?'[redacted]':v;
    (clone.careerApps||[]).forEach(x=>{x.company=mask(x.company); if(!includeNotes) x.notes='';});
    (clone.smbInvoices||[]).forEach(x=>{x.client=mask(x.client);});
    (clone.smbVendors||[]).forEach(x=>{x.name=mask(x.name); if(!includeNotes) x.note='';});
    (clone.healthCases||[]).forEach(x=>{x.payer=mask(x.payer); if(!includeNotes) x.notes='';});
  } else if(!includeNotes){
    (clone.careerApps||[]).forEach(x=>x.notes='');
    (clone.smbVendors||[]).forEach(x=>x.note='');
    (clone.healthCases||[]).forEach(x=>x.notes='');
  }
  if (!includeAudit) clone.audit = [];
  return { ok:true, exportedAt:new Date().toISOString(), checksum: stateChecksum(), package: clone };
});

fastify.post('/api/data/import-preview', async (req)=>{
  const pkg = req.body?.package;
  if (!pkg) return { ok:false, error:'package missing' };
  const checks = {
    hasVersion: !!pkg.stateVersion,
    hasSettings: !!pkg.settings,
    hasModules: !!pkg.modules,
    arrays: Array.isArray(pkg.items) && Array.isArray(pkg.actions)
  };
  return { ok:true, valid:Object.values(checks).every(Boolean), checks, counts:{ items:(pkg.items||[]).length, actions:(pkg.actions||[]).length } };
});

fastify.post('/api/data/import-apply', async (req)=>{
  const pkg = req.body?.package;
  if (!pkg) return { ok:false, error:'package missing' };
  saveBackup();
  const loaded = migrateState(pkg);
  Object.keys(state).forEach(k=>delete state[k]);
  Object.assign(state, loaded);
  saveState();
  audit('data_import_applied',{});
  return { ok:true };
});

fastify.post('/api/data/clear', async (req)=>{ const user=currentUser(req); if(!can(user,'all')) return {ok:false,error:'permission denied'};
  const module = String(req.body?.module || '');
  const phrase = String(req.body?.confirmPhrase || '');
  if (phrase !== 'CLEAR DATA') return { ok:false, error:'confirm phrase required: CLEAR DATA' };
  if (module==='career') state.careerApps=[];
  else if (module==='smb') { state.smbInvoices=[]; state.smbCompliance=[]; state.smbVendors=[]; }
  else if (module==='health') state.healthCases=[];
  else if (module==='all') {
    state.items=[]; state.actions=[]; state.approvals=[]; state.audit=[]; state.notifications=[];
    state.careerApps=[]; state.smbInvoices=[]; state.smbCompliance=[]; state.smbVendors=[]; state.healthCases=[];
  }
  saveState(); audit('data_cleared',{module});
  return { ok:true };
});

fastify.get('/api/data/integrity', async ()=>({
  ok:true,
  stateVersion: state.stateVersion,
  checksum: stateChecksum(),
  counts: {
    items: state.items.length, actions: state.actions.length, audit: state.audit.length, notifications: state.notifications.length,
    career: state.careerApps.length, smbInvoices: state.smbInvoices.length, smbCompliance: state.smbCompliance.length, smbVendors: state.smbVendors.length, health: state.healthCases.length
  },
  backupCount: fs.existsSync(BACKUP_DIR) ? fs.readdirSync(BACKUP_DIR).filter(x=>x.endsWith('.json')).length : 0
}));


function currentUser(req){
  const uid = String(req.headers['x-lifeops-user'] || 'u-owner');
  return state.users.find(u=>u.id===uid) || state.users[0];
}
function can(user, action){
  const perms = {
    owner: ['all'],
    member: ['read','write','propose','update'],
    viewer: ['read']
  };
  const p = perms[user.role] || ['read'];
  return p.includes('all') || p.includes(action);
}

fastify.get('/api/users', async ()=> state.users);
fastify.post('/api/users', async (req)=>{
  const b=req.body||{};
  const u={ id: crypto.randomUUID(), name:b.name||'User', role:b.role||'viewer' };
  state.users.push(u); saveState(); audit('user_added',{id:u.id,role:u.role}); return {ok:true,user:u};
});

fastify.get('/api/user/me', async (req)=> ({ ok:true, user: currentUser(req) }));


fastify.patch('/api/onboarding', async (req)=>{
  const b=req.body||{};
  if (typeof b.beginnerMode==='boolean') state.settings.beginnerMode = b.beginnerMode;
  if (typeof b.setupComplete==='boolean') state.settings.setupComplete = b.setupComplete;
  saveState();
  audit('onboarding_updated',{beginnerMode:state.settings.beginnerMode,setupComplete:state.settings.setupComplete});
  return { ok:true, settings: state.settings };
});

fastify.get('/api/health', async () => ({ ok: true, app: 'lifeops-copilot' }));
fastify.get('/api/perf', async ()=>({ ok:true, counts:{items:state.items.length,actions:state.actions.length,audit:state.audit.length,notifications:state.notifications.length}, scheduler: state.settings.scheduler }));

fastify.get('/api/selfcheck', async ()=>{
  const checks = {
    stateFileExists: fs.existsSync(DB_PATH),
    stateVersion: !!state.stateVersion,
    arraysPresent: Array.isArray(state.items)&&Array.isArray(state.actions)&&Array.isArray(state.audit),
    modulesPresent: !!state.modules
  };
  return { ok:true, passed:Object.values(checks).every(Boolean), checks, stateVersion: state.stateVersion };
});


fastify.get('/api/notifications', async ()=> state.notifications.slice(-200).reverse());
fastify.get('/api/notifications/my', async (req)=>{ const u=currentUser(req); return state.notifications.slice(-200).reverse().map(n=>({ ...n, audience:u.role })); });
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

fastify.post('/api/actions/:id/approve', async (req, reply) => { const user=currentUser(req); if(!can(user,'propose')) return reply.code(403).send({ok:false,error:'permission denied'});
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


fastify.get('/api/export/common', async (req)=>{
  const redacted = req.query?.redacted === '1' || state.security.redactionDefault;
  return {
    ok:true,
    generatedAt:new Date().toISOString(),
    modules: state.modules,
    queue: (redacted ? combinedQueue().map(x=>({ ...x, title: x.source==='health' ? '[redacted]' : x.title })) : combinedQueue()),
    counts: {
      paperwork: state.items.length,
      opportunities: state.opportunityActions.length,
      career: state.careerApps.length,
      smbInvoices: state.smbInvoices.length,
      smbCompliance: state.smbCompliance.length,
      healthCases: state.healthCases.length
    }
  };
});

fastify.get('/api/audit', async ()=> state.audit.slice(-200).reverse());

fastify.listen({ port: 3360, host: '0.0.0.0' });
