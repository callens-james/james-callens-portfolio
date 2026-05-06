import json
from pathlib import Path

CACHE = Path(__file__).resolve().parents[1] / 'data' / 'advisories_cache.json'
SEED = Path(__file__).resolve().parents[1] / 'data' / 'cve_seed.json'


def _load_items():
    if CACHE.exists():
        try:
            j=json.loads(CACHE.read_text())
            return j.get('items', [])
        except Exception:
            pass
    try:
        return json.loads(SEED.read_text())
    except Exception:
        return []


def find_evidence(text:str, top_k:int=3):
    text_l=(text or '').lower()
    items=[]
    for row in _load_items():
        score=0
        for t in row.get('tags',[]):
            if t.lower() in text_l:
                score += 2
        sm=(row.get('summary') or '').lower()
        for kw in ['sql','injection','token','auth','command','xss','jwt','rce']:
            if kw in text_l and kw in sm:
                score += 1
        if score>0:
            items.append((score,row))
    items.sort(key=lambda x:(x[0], x[1].get('severity','')), reverse=True)
    return [r for _,r in items[:top_k]]
