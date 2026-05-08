from __future__ import annotations
import time, secrets
from pathlib import Path

_CAPS = {}


def issue_capability(actor:str, workspace:str, actionClass:str='modify_files', allowedPaths=None, deniedPaths=None, maxFiles:int=20, ttl:int=600):
    allowedPaths = allowedPaths or ["**"]
    deniedPaths = deniedPaths or ['.env', '.env.local', '.git/**', '~/.ssh/**', '/etc/**']
    tok = secrets.token_urlsafe(24)
    _CAPS[tok] = {
      'actor': actor,
      'workspace': workspace,
      'actionClass': actionClass,
      'allowedPaths': allowedPaths,
      'deniedPaths': deniedPaths,
      'maxFiles': maxFiles,
      'exp': int(time.time()) + max(60, ttl),
      'usedCount': 0,
      'parent': None,
    }
    return {'ok': True, 'capabilityToken': tok, 'capability': _CAPS[tok]}


def inherit_capability(parentToken:str, actor:str, ttl:int=300):
    p=_CAPS.get(parentToken)
    if not p: return {'ok':False,'error':'missing parent'}
    if p.get('exp',0) < int(time.time()): return {'ok':False,'error':'parent expired'}
    child = issue_capability(actor=actor, workspace=p['workspace'], actionClass=p['actionClass'], allowedPaths=p['allowedPaths'], deniedPaths=p['deniedPaths'], maxFiles=p['maxFiles'], ttl=min(ttl, p['exp']-int(time.time())))
    if child.get('ok'):
        _CAPS[child['capabilityToken']]['parent']=parentToken
    return child


def validate_capability(token:str, actor:str, workspace:str):
    c=_CAPS.get(token)
    if not c: return {'ok':False,'reason':'missing'}
    if c.get('exp',0) < int(time.time()): return {'ok':False,'reason':'expired'}
    if c.get('actor') != actor: return {'ok':False,'reason':'actor-mismatch'}
    if c.get('workspace') != workspace: return {'ok':False,'reason':'workspace-mismatch'}
    c['usedCount']=c.get('usedCount',0)+1
    _CAPS[token]=c
    return {'ok':True,'capability':c}
