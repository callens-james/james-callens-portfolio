from __future__ import annotations
import hashlib, time
from agents.safety_policy import evaluate_command

_APPROVAL_CACHE = {}


def _fingerprint(cmd:str)->str:
    return hashlib.sha256(cmd.encode()).hexdigest()[:16]


def evaluate_global_action(action:str, cmd:str):
    """Single-prompt global gate model.
    Returns normalized decision envelope for UI/agent surfaces.
    """
    pe = evaluate_command(cmd)
    fp = _fingerprint(cmd)
    now = int(time.time())
    cached = _APPROVAL_CACHE.get(fp)

    if cached and cached.get('exp',0) > now and pe.get('verdict') in ('allow','warn'):
        return {
          'allowed': True,
          'needsPrompt': False,
          'approvalReused': True,
          'approvalToken': fp,
          'policy': pe,
          'message': 'Recent approval reused.'
        }

    verdict = pe.get('verdict','allow')
    needs = pe.get('needsConfirm', False) or verdict in ('warn','block')
    typed = pe.get('typedConfirm', False) or verdict == 'block'

    if verdict == 'allow' and not needs:
        return {
          'allowed': True,
          'needsPrompt': False,
          'approvalReused': False,
          'approvalToken': fp,
          'policy': pe,
          'message': 'Allowed (low risk).'
        }

    return {
      'allowed': False,
      'needsPrompt': True,
      'typedConfirm': typed,
      'approvalReused': False,
      'approvalToken': fp,
      'policy': pe,
      'message': 'Approval required before execution.'
    }


def approve(token:str, cmd:str, action:str='command', workspace:str='/workspace', actor:str='local', ttl_seconds:int=600):
    _APPROVAL_CACHE[token] = {'exp': int(time.time()) + max(60, ttl_seconds), 'cmdHash': _fingerprint(cmd), 'used': False, 'action': action, 'workspace': workspace, 'actor': actor}
    return {'ok': True, 'token': token, 'ttl': ttl_seconds}


def consume_approval(token:str, cmd:str, action:str='command', workspace:str='/workspace', actor:str='local'):
    now=int(time.time())
    ent=_APPROVAL_CACHE.get(token)
    if not ent: return {'ok':False,'reason':'missing'}
    if ent.get('used'): return {'ok':False,'reason':'used'}
    if ent.get('exp',0) < now: return {'ok':False,'reason':'expired'}
    if ent.get('cmdHash') != _fingerprint(cmd): return {'ok':False,'reason':'cmd-mismatch'}
    if ent.get('action') != action: return {'ok':False,'reason':'action-mismatch'}
    if ent.get('workspace') != workspace: return {'ok':False,'reason':'workspace-mismatch'}
    if ent.get('actor') != actor: return {'ok':False,'reason':'actor-mismatch'}
    ent['used']=True
    _APPROVAL_CACHE[token]=ent
    return {'ok':True}
