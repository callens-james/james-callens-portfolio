from pathlib import Path
import subprocess
from watchers.registry import approved_projects

EXCLUDE_PATTERNS = [
    "/backend/watchers/change_queue.jsonl",
    "/backend/data_reports.jsonl",
    "/.venv/",
    "/__pycache__/"
]

def _excluded(path:Path):
    sp=str(path)
    return any(x in sp for x in EXCLUDE_PATTERNS)

def _in_approved(path:Path):
    for root in approved_projects():
        r=Path(root)
        if r == path or r in path.parents:
            return True
    return False

def find_repo_root(file_path:str):
    p = Path(file_path).resolve()
    cur = p if p.is_dir() else p.parent
    while cur != cur.parent:
        if (cur / '.git').exists() and _in_approved(cur):
            return cur
        cur = cur.parent
    return None

def changed_files(repo_root:Path):
    try:
        out = subprocess.check_output(['git','-C',str(repo_root),'diff','--name-only'], text=True)
    except Exception:
        return []
    files=[]
    for rel in out.splitlines():
        rel=rel.strip()
        if not rel:
            continue
        f=(repo_root / rel).resolve()
        if _in_approved(f) and not _excluded(f):
            files.append(str(f))
    return files
