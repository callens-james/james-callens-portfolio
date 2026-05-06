import json
from pathlib import Path

REG = Path(__file__).with_name('project_registry.json')

def load_registry():
    return json.loads(REG.read_text())

def approved_projects():
    cfg=load_registry()
    return [str(Path(p).resolve()) for p in cfg.get('approvedProjects',[])]

def is_approved(path:str):
    p=Path(path).resolve()
    for root in approved_projects():
        r=Path(root)
        if r == p or r in p.parents:
            return True
    return False
