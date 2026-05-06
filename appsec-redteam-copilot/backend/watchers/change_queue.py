import json
from datetime import datetime
from pathlib import Path
from threading import Lock

QUEUE_FILE = Path(__file__).with_name('change_queue.jsonl')
_lock = Lock()

def push(path:str, event:str):
    item = {"time": datetime.utcnow().isoformat(), "path": path, "event": event}
    line = json.dumps(item, ensure_ascii=False)
    with _lock:
        with QUEUE_FILE.open('a', encoding='utf-8') as f:
            f.write(line + "\n")

def list_items(limit=200):
    if not QUEUE_FILE.exists():
        return []
    with _lock:
        lines = QUEUE_FILE.read_text(encoding='utf-8', errors='ignore').splitlines()
    out=[]
    for ln in lines[-limit:]:
        try:
            out.append(json.loads(ln))
        except Exception:
            continue
    return out
