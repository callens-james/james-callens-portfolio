from __future__ import annotations
import hashlib, os, shlex, subprocess, time
from pathlib import Path
from agents.safety_policy import evaluate_command, audit
from agents.global_gate import evaluate_global_action, approve, consume_approval

PROTECTED_PREFIXES = [
    '/home/james/.ssh',
    '/etc', '/boot', '/root', '/var/lib', '/usr', '/bin', '/sbin', '/lib', '/lib64',
]
PROTECTED_NAMES = {'.env', '.env.local', 'id_rsa', 'id_ed25519', 'authorized_keys'}
WORKSPACE_ROOT = '/workspace'

def _within(root:str, path:str)->bool:
    try:
        rr=Path(root).resolve()
        rp=Path(path).resolve()
        return rp == rr or rr in rp.parents
    except Exception:
        return False


def _real(p:str)->str:
    try:
        pp=Path(p).expanduser()
        if pp.exists():
            return str(pp.resolve())
        parent = pp.parent if str(pp.parent) else Path('.')
        return str((parent.resolve()/pp.name))
    except Exception:
        return p


def _paths_from_cmd(cmd:str):
    out=[]
    for t in shlex.split(cmd):
        if t.startswith('/') or t.startswith('./') or t.startswith('../') or t.startswith('~'):
            out.append(_real(t))
    return out


def _is_protected(path:str)->bool:
    rp=_real(path)
    name=Path(rp).name
    if name in PROTECTED_NAMES:
        return True
    return any(rp == p or rp.startswith(p + '/') for p in PROTECTED_PREFIXES)


def check_mutation(cmd:str):
    gate = evaluate_global_action('command', cmd)
    paths = _paths_from_cmd(cmd)
    outside = [p for p in paths if not _within(WORKSPACE_ROOT, p)]
    protected = [p for p in paths if _is_protected(p)]
    if outside:
        gate['allowed'] = False
        gate['needsPrompt'] = True
        gate['typedConfirm'] = True
        gate['policy']['verdict'] = 'block'
        gate['policy']['risk'] = 'high'
        gate['policy']['reason'] = 'workspace-containment-fail'
        gate['outsideScopePaths'] = outside
    if protected:
        gate['allowed'] = False
        gate['needsPrompt'] = True
        gate['typedConfirm'] = True
        gate['policy']['verdict'] = 'block'
        gate['policy']['risk'] = 'high'
        gate['policy']['reason'] = 'protected-path-floor'
        gate['protectedPaths'] = protected
    gate['pathScope'] = paths
    return gate


def grant(token:str, cmd:str, ttl:int=300):
    return approve(token, cmd=cmd, ttl_seconds=ttl)


def exec_with_token(cmd:str, token:str=''):
    decision = check_mutation(cmd)
    required = decision.get('needsPrompt', False) or not decision.get('allowed', False)
    expected = decision.get('approvalToken', '')
    if required:
        if token != expected:
            audit({'type':'broker-deny','cmd':cmd,'reason':'approval-required','tokenExpected':expected})
            return {'ok': False, 'error': 'approval required', 'decision': decision}
        c = consume_approval(token, cmd)
        if not c.get('ok'):
            audit({'type':'broker-deny','cmd':cmd,'reason':c.get('reason','token-invalid')})
            return {'ok': False, 'error': f'approval token invalid: {c.get("reason")}', 'decision': decision}

    audit({'type':'broker-exec','cmd':cmd,'decision':decision.get('policy',{}).get('reason','')})
    p = subprocess.run(['bash','-lc',cmd], capture_output=True, text=True)
    return {
      'ok': p.returncode == 0,
      'returncode': p.returncode,
      'stdout': p.stdout[-4000:],
      'stderr': p.stderr[-4000:],
      'decision': decision
    }
