import json
from datetime import datetime
from pathlib import Path

STORE = Path(__file__).resolve().parents[1] / 'data_reports.jsonl'

def save_report(report:dict):
    row = {"savedAt": datetime.utcnow().isoformat(), **report}
    with STORE.open('a', encoding='utf-8') as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")
    return row

def list_reports(limit=100):
    if not STORE.exists():
        return []
    lines = STORE.read_text(encoding='utf-8', errors='ignore').splitlines()
    out=[]
    for ln in lines[-limit:]:
        try:
            out.append(json.loads(ln))
        except Exception:
            continue
    return out
