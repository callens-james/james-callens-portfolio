from __future__ import annotations
import hashlib, os, shlex, subprocess, time
from pathlib import Path
from agents.safety_policy import evaluate_command, audit
from agents.global_gate import evaluate_global_action, approve

PROTECTED_PREFIXES = [
    '/etc', '/boot', '/root', '/var/lib', '/usr', '/bin', '/sbin', '/lib', '/lib64',
]
PROTECTED_NAMES = {'.env', '.env.local', 'id_rsa', 'id_ed25519', 'authorized_keys'}


def _real(p:str)->str:
    try:
        return str(Path(p).expanduser().resolve())
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
    protected = [p for p in paths if _is_protected(p)]
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


def grant(token:str, ttl:int=300):
    return approve(token, ttl_seconds=ttl)


def exec_with_token(cmd:str, token:str=''):
    decision = check_mutation(cmd)
    required = decision.get('needsPrompt', False) or not decision.get('allowed', False)
    expected = decision.get('approvalToken', '')
    if required and token != expected:
        audit({'type':'broker-deny','cmd':cmd,'reason':'approval-required','tokenExpected':expected})
        return {'ok': False, 'error': 'approval required', 'decision': decision}

    # if token passed, cache approval shortly
    if token:
        grant(token, ttl=300)

    audit({'type':'broker-exec','cmd':cmd,'decision':decision.get('policy',{}).get('reason','')})
    p = subprocess.run(['bash','-lc',cmd], capture_output=True, text=True)
    return {
      'ok': p.returncode == 0,
      'returncode': p.returncode,
      'stdout': p.stdout[-4000:],
      'stderr': p.stderr[-4000:],
      'decision': decision
    }
