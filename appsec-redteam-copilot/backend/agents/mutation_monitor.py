from __future__ import annotations
import json, time
from pathlib import Path
from agents.safety_policy import audit

BASE = Path('/app/backend')
BASELINE = Path('/app/backend/data/mutation_baseline.json')
ALERTS = Path('/app/backend/data/mutation_monitor_alerts.jsonl')

WATCH_DIRS = [
    Path('/app/backend/api'),
    Path('/app/backend/agents'),
    Path('/app/backend/watchers'),
    Path('/app/backend/frontend'),
]


def _scan():
    rows = {}
    for d in WATCH_DIRS:
        if not d.exists():
            continue
        for p in d.rglob('*'):
            if not p.is_file():
                continue
            try:
                st = p.stat()
                rows[str(p)] = {'mtime': int(st.st_mtime), 'size': int(st.st_size)}
            except Exception:
                pass
    return rows


def capture_baseline():
    now = int(time.time())
    rows = _scan()
    BASELINE.parent.mkdir(parents=True, exist_ok=True)
    BASELINE.write_text(json.dumps({'ts': now, 'files': rows}, indent=2))
    return {'ok': True, 'files': len(rows), 'ts': now}


def detect_out_of_band():
    if not BASELINE.exists():
        return {'ok': False, 'error': 'baseline missing'}
    old = json.loads(BASELINE.read_text())
    prev = old.get('files', {})
    cur = _scan()
    changes = []
    for path, meta in cur.items():
        o = prev.get(path)
        if not o:
            changes.append({'path': path, 'type': 'new'})
        elif o.get('mtime') != meta.get('mtime') or o.get('size') != meta.get('size'):
            changes.append({'path': path, 'type': 'modified'})
    for path in prev:
        if path not in cur:
            changes.append({'path': path, 'type': 'deleted'})

    if changes:
        ALERTS.parent.mkdir(parents=True, exist_ok=True)
        evt = {'ts': int(time.time()), 'count': len(changes), 'changes': changes[:200]}
        with ALERTS.open('a') as f:
            f.write(json.dumps(evt) + '\n')
        audit({'type': 'out-of-band-mutation-detected', 'count': len(changes)})
    return {'ok': True, 'count': len(changes), 'changes': changes[:200]}
