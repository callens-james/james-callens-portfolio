from __future__ import annotations
from pathlib import Path
import hashlib
import json, re, time

POLICY_PATH = Path('/app/backend/data/safety_policy.json')
AUDIT_PATH = Path('/app/backend/data/safety_audit.jsonl')

DEFAULT_POLICY = {
  'agentSafeMode': True,
  'commandGuard': True,
  'alwaysConfirmHighImpact': True,
  'requireTypedConfirmForDestructive': True,
  'workspaceScopeLock': True,
  'workspaceRoot': '/workspace',
  'batchFileLimit': 100,
  'brokerOnlyMode': True,
  'requirePolicyAdminConfirm': True,
  'policyAdminPhrase': 'CONFIRM POLICY CHANGE',
}

DESTRUCTIVE = [
  re.compile(r'(^|\s)rm\s+-rf\s+/(\s|$)'),
  re.compile(r'(^|\s)rm\s+-rf\s+--no-preserve-root(\s|$)'),
  re.compile(r'(^|\s)mkfs\.'),
  re.compile(r'(^|\s)dd\s+if=/dev/(zero|random)\s+of=/dev/'),
  re.compile(r'(^|\s)shred\s+.*\s/dev/'),
  re.compile(r'(^|\s)chmod\s+-R\s+777\s+/'),
]

WRITEY = [re.compile(r'(^|\s)(rm|mv|cp|chmod|chown|sed\s+-i|truncate|tee\s|cat\s+>)(\s|$)')]


def load_policy():
    if POLICY_PATH.exists():
        try:
            data = json.loads(POLICY_PATH.read_text())
            merged = {**DEFAULT_POLICY, **data}
            return merged
        except Exception:
            pass
    POLICY_PATH.parent.mkdir(parents=True, exist_ok=True)
    POLICY_PATH.write_text(json.dumps(DEFAULT_POLICY, indent=2))
    return dict(DEFAULT_POLICY)


def save_policy(p: dict):
    merged = {**DEFAULT_POLICY, **p}
    POLICY_PATH.parent.mkdir(parents=True, exist_ok=True)
    POLICY_PATH.write_text(json.dumps(merged, indent=2))
    return merged


def classify_command(cmd: str):
    destructive = any(rx.search(cmd) for rx in DESTRUCTIVE)
    mutating = destructive or any(rx.search(cmd) for rx in WRITEY)
    return {'destructive': destructive, 'mutating': mutating}


def evaluate_command(cmd: str, triage_verdict='allow', triage_risk='low'):
    p = load_policy()
    c = classify_command(cmd)
    out = {
      'policy': p,
      'destructive': c['destructive'],
      'mutating': c['mutating'],
      'needsConfirm': False,
      'typedConfirm': False,
      'verdict': triage_verdict,
      'risk': triage_risk,
      'reason': 'triage'
    }

    if c['destructive'] and p.get('alwaysConfirmHighImpact', True):
        out['needsConfirm'] = True
        out['typedConfirm'] = p.get('requireTypedConfirmForDestructive', True)
        out['reason'] = 'high-impact-safety-floor'
        if triage_verdict != 'block':
            out['verdict'] = 'warn'
            out['risk'] = 'high'

    if not p.get('commandGuard', True) and c['destructive']:
        # even when guard off, keep safety floor
        out['needsConfirm'] = True
        out['typedConfirm'] = True
        out['verdict'] = 'warn'
        out['risk'] = 'high'
        out['reason'] = 'guard-off-safety-floor'

    scope = enforce_scope_and_batch(cmd)
    out['scope'] = scope
    if scope.get('outsideScope'):
        out['needsConfirm'] = True
        out['typedConfirm'] = True
        out['verdict'] = 'warn' if out['verdict'] != 'block' else out['verdict']
        out['risk'] = 'high'
        out['reason'] = 'workspace-scope-lock'
    if scope.get('batchExceeded'):
        out['needsConfirm'] = True
        out['typedConfirm'] = True
        if out['verdict'] != 'block':
            out['verdict'] = 'warn'
        out['reason'] = 'batch-limit'

    return out


def audit(event: dict):
    AUDIT_PATH.parent.mkdir(parents=True, exist_ok=True)
    prev='GENESIS'
    if AUDIT_PATH.exists():
        lines=AUDIT_PATH.read_text(errors='ignore').splitlines()
        for ln in reversed(lines):
            try:
                j=json.loads(ln)
                prev=j.get('entryHash','GENESIS')
                break
            except Exception:
                continue
    row = {'ts': int(time.time()), **event, 'prevHash': prev}
    canon=json.dumps(row, sort_keys=True)
    row['entryHash']=hashlib.sha256(canon.encode()).hexdigest()
    with AUDIT_PATH.open('a') as f:
        f.write(json.dumps(row) + '\n')

def verify_audit_chain(limit:int=5000):
    if not AUDIT_PATH.exists():
        return {'ok': True, 'checked': 0, 'errors': []}
    lines=AUDIT_PATH.read_text(errors='ignore').splitlines()[-limit:]
    prev='GENESIS'
    errors=[]
    checked=0
    for i,ln in enumerate(lines, start=1):
        try:
            row=json.loads(ln)
            claimed_prev=row.get('prevHash','')
            claimed_hash=row.get('entryHash','')
            tmp=dict(row)
            tmp.pop('entryHash',None)
            calc=hashlib.sha256(json.dumps(tmp, sort_keys=True).encode()).hexdigest()
            if claimed_prev != prev:
                errors.append({'line':i,'type':'prev_mismatch'})
            if claimed_hash != calc:
                errors.append({'line':i,'type':'hash_mismatch'})
            prev=claimed_hash or prev
            checked+=1
        except Exception:
            errors.append({'line':i,'type':'parse_error'})
    genesis_count=sum(1 for ln in lines if '"prevHash": "GENESIS"' in ln)
    if checked>1 and genesis_count>1:
        errors.append({'line':0,'type':'multiple_genesis_possible_truncation'})
    return {'ok': len(errors)==0, 'checked': checked, 'errors': errors, 'genesisCount': genesis_count, 'lastHash': prev}


def _extract_paths(cmd:str):
    toks = cmd.split()
    out=[]
    for t in toks:
        if t.startswith('/') or t.startswith('./') or t.startswith('../') or t.startswith('~'):
            out.append(t)
    return out

def enforce_scope_and_batch(cmd:str):
    p = load_policy()
    paths = _extract_paths(cmd)
    out = {'outsideScope': False, 'pathCount': len(paths), 'batchExceeded': False, 'paths': paths}
    root = p.get('workspaceRoot','/workspace')
    if p.get('workspaceScopeLock', True):
        for x in paths:
            xp = x.replace('~','/home/james')
            if not xp.startswith(root):
                out['outsideScope']=True
                break
    if len(paths) > int(p.get('batchFileLimit',100)):
        out['batchExceeded']=True
    return out
