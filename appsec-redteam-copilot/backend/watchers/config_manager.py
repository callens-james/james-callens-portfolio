import json
from pathlib import Path

REG = Path(__file__).with_name('project_registry.json')
WATCH = Path(__file__).with_name('watch_config.json')


def _read(p):
    return json.loads(Path(p).read_text())

def _write(p, obj):
    Path(p).write_text(json.dumps(obj, indent=2))

def get_config():
    return {'registry': _read(REG), 'watch': _read(WATCH)}

def set_workspace_root(path:str):
    r=_read(REG); w=_read(WATCH)
    r['workspaceRoot']=path
    w['workspaceRoot']=path
    _write(REG,r); _write(WATCH,w)
    return get_config()

def add_project(path:str):
    r=_read(REG)
    ap=r.get('approvedProjects',[])
    if path not in ap:
        ap.append(path)
    r['approvedProjects']=ap
    _write(REG,r)
    return r

def remove_project(path:str):
    r=_read(REG)
    ap=[x for x in r.get('approvedProjects',[]) if x!=path]
    r['approvedProjects']=ap
    _write(REG,r)
    return r
