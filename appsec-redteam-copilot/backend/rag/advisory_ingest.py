import json
from pathlib import Path
from datetime import datetime
import requests

CACHE = Path(__file__).resolve().parents[1] / 'data' / 'advisories_cache.json'
SEED = Path(__file__).resolve().parents[1] / 'data' / 'cve_seed.json'


def _load_seed():
    try:
        return json.loads(SEED.read_text())
    except Exception:
        return []


def fetch_github_advisories(limit=50):
    # public endpoint without token can be rate-limited; best-effort
    url = 'https://api.github.com/advisories'
    params = {'per_page': min(limit, 100)}
    r = requests.get(url, params=params, timeout=20, headers={'Accept':'application/vnd.github+json'})
    if r.status_code != 200:
        return []
    data = r.json()
    out=[]
    for row in data[:limit]:
        cve = row.get('cve_id') or row.get('ghsa_id') or 'GHSA-UNKNOWN'
        summary = row.get('summary') or ''
        sev = (row.get('severity') or 'unknown').lower()
        tags=[]
        txt=(summary+' '+(row.get('description') or '')).lower()
        for t in ['sql','injection','xss','rce','auth','token','jwt','command','deserialization','csrf']:
            if t in txt:
                tags.append(t)
        out.append({'id':cve,'tags':sorted(set(tags)),'summary':summary,'severity':sev,'ref':row.get('html_url','')})
    return out


def refresh_cache(limit=50):
    seed = _load_seed()
    live = fetch_github_advisories(limit=limit)
    merged = {x['id']:x for x in seed}
    for x in live:
        merged[x['id']] = x
    payload = {
        'refreshedAt': datetime.utcnow().isoformat(),
        'count': len(merged),
        'items': list(merged.values())
    }
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(json.dumps(payload, ensure_ascii=False, indent=2))
    return payload
