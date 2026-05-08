from __future__ import annotations
from pathlib import Path
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

    return out


def audit(event: dict):
    AUDIT_PATH.parent.mkdir(parents=True, exist_ok=True)
    row = {'ts': int(time.time()), **event}
    with AUDIT_PATH.open('a') as f:
        f.write(json.dumps(row) + '\n')
