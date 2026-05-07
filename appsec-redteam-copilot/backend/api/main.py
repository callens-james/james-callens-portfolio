from fastapi import FastAPI, Query
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from datetime import datetime
from pathlib import Path
import json

from watchers.change_queue import list_items
from agents.triage_rules import triage_file, triage_snippet
from agents.alerts import should_alert, send_telegram_alert, build_alert
from evaluators.report_store import save_report, list_reports
from rag.git_diff import find_repo_root, changed_files
from rag.advisory_ingest import refresh_cache
from rag.diff_hunks import get_unified_diff, parse_added_hunks
from evaluators.run_eval import run_eval
from evaluators.render_report import render_markdown
from watchers.config_manager import get_config, set_workspace_root, add_project, remove_project

app = FastAPI(title="AppSec Red Team Copilot", version="0.1.1")
CFG = Path(__file__).resolve().parents[1] / 'watchers' / 'watch_config.json'

class AnalyzeRequest(BaseModel):
    project: str
    files: list[str] = []

@app.get('/health')
def health():
    return {"ok": True, "service": "appsec-redteam-copilot", "time": datetime.utcnow().isoformat()}

@app.get('/changes')
def changes(limit:int=Query(100, ge=1, le=1000)):
    return {"items": list_items(limit)}

@app.post('/analyze-diff')
def analyze_diff(req: AnalyzeRequest):
    reports=[triage_file(f) for f in req.files]
    overall='low'
    if any(r['risk']=='high' for r in reports):
        overall='high'
    elif any(r['risk']=='medium' for r in reports):
        overall='medium'
    return {
        "project": req.project,
        "summary": f"Analyzed {len(req.files)} files",
        "risk": overall,
        "findings": reports,
        "next": ["connect git diff extractor", "connect RAG evidence"]
    }
# test Wed May  6 02:46:54 PM UTC 2026
# test Wed May  6 02:50:04 PM UTC 2026


@app.post('/analyze-recent')
def analyze_recent(limit:int=Query(25, ge=1, le=500)):
    items = list_items(limit)
    files = []
    seen = set()
    for it in items:
        p = it.get('path')
        if p and p not in seen:
            seen.add(p)
            files.append(p)
    reports=[triage_file(f) for f in files]
    overall='low'
    if any(r['risk']=='high' for r in reports):
        overall='high'
    elif any(r['risk']=='medium' for r in reports):
        overall='medium'
    payload = {
        'project': 'workspace-recent',
        'summary': f'Analyzed {len(files)} recent changed files',
        'risk': overall,
        'findings': reports,
        'sourceCount': len(items)
    }
    saved = save_report(payload)
    return saved

@app.get('/reports')
def reports(limit:int=Query(50, ge=1, le=1000)):
    return {'items': list_reports(limit)}
# test Wed May  6 06:23:06 PM UTC 2026


@app.post('/analyze-repo-diff')
def analyze_repo_diff(path:str):
    root = find_repo_root(path)
    if not root:
        return {'error':'no git repo root found', 'path': path}
    files = changed_files(root)
    reports=[triage_file(f) for f in files]
    overall='low'
    if any(r.get('risk')=='high' for r in reports):
        overall='high'
    elif any(r.get('risk')=='medium' for r in reports):
        overall='medium'
    verdict='allow'
    if overall == 'high':
        verdict='block'
    elif overall == 'medium':
        verdict='warn'
    payload = {
      'project': str(root),
      'summary': f'Analyzed git diff files: {len(files)}',
      'risk': overall,
      'verdict': verdict,
      'findings': reports,
      'source':'git-diff'
    }
    return save_report(payload)
# test Wed May  6 07:20:48 PM UTC 2026
# test Wed May  6 07:22:51 PM UTC 2026


@app.post('/advisories/refresh')
def advisories_refresh(limit:int=Query(50, ge=1, le=100)):
    return refresh_cache(limit=limit)


@app.post('/eval/run')
def eval_run():
    summary, out = run_eval()
    return {'report': str(out), 'riskAccuracy': summary['riskAccuracy'], 'typeCoverage': summary['typeCoverage'], 'cases': summary['cases']}


@app.post('/report/markdown')
def report_markdown(path:str):
    root = find_repo_root(path)
    if not root:
        return {'error':'no git repo root found', 'path': path}
    files = changed_files(root)
    reports=[triage_file(f) for f in files]
    overall='low'
    if any(r.get('risk')=='high' for r in reports):
        overall='high'
    elif any(r.get('risk')=='medium' for r in reports):
        overall='medium'
    payload = {
      'project': str(root),
      'summary': f'Analyzed git diff files: {len(files)}',
      'risk': overall,
      'findings': reports,
      'source':'git-diff'
    }
    md = render_markdown(payload)
    out = Path('/app/backend/data/SECURITY_REPORT.md')
    out.write_text(md)
    return {'path': str(out), 'risk': overall, 'filesAnalyzed': len(files)}
# safe comment


@app.get('/dashboard', response_class=HTMLResponse)
def dashboard():
    f = Path(__file__).resolve().parents[1] / 'frontend' / 'dashboard.html'
    return f.read_text(encoding='utf-8')


@app.post('/analyze-diff-hunks')
def analyze_diff_hunks(path:str):
    root = find_repo_root(path)
    if not root:
        return {'error':'no git repo root found', 'path': path}
    diff_text = get_unified_diff(root)
    added = parse_added_hunks(diff_text)
    analyzed=[]
    for a in added:
        file_abs = str((root / a['file']).resolve())
        r = triage_snippet(file_abs, a['line'], a['added'])
        if r['findings']:
            analyzed.append(r)
    overall='low'
    if any(x['risk']=='high' for x in analyzed): overall='high'
    elif any(x['risk']=='medium' for x in analyzed): overall='medium'
    verdict='allow'
    if overall == 'high':
        verdict='block'
    elif overall == 'medium':
        verdict='warn'
    payload={'project':str(root),'summary':f'Analyzed added lines: {len(added)}','risk':overall,'verdict':verdict,'findings':analyzed,'source':'pre-change-diff'}
    return save_report(payload)


@app.post('/alerts/test')
def alerts_test(msg:str='AppSec test alert ✅'):
    result = send_telegram_alert(msg)
    return {'ok': True, 'result': result}


@app.post('/analyze-command')
def analyze_command(cmd:str):
    r = triage_snippet('/local/command', 1, cmd)
    verdict='allow'
    if r.get('risk') == 'high':
        verdict='block'
    elif r.get('risk') == 'medium':
        verdict='warn'
    payload={'project':'local-shell','summary':'Analyzed command string','risk':r.get('risk','low'),'verdict':verdict,'findings':[r],'source':'command-string'}
    saved = save_report(payload)
    if should_alert(saved.get('verdict','allow')):
        send_telegram_alert(build_alert(saved))
    return saved


@app.get('/config/watch')
def config_watch():
    return get_config()

@app.post('/config/workspace-root')
def config_workspace_root(path:str):
    return set_workspace_root(path)

@app.post('/config/projects/add')
def config_projects_add(path:str):
    return add_project(path)

@app.post('/config/projects/remove')
def config_projects_remove(path:str):
    return remove_project(path)


@app.get('/fs/list')
def fs_list(path:str='/'):
    from pathlib import Path
    p = Path(path).expanduser().resolve()
    if not p.exists() or not p.is_dir():
        return {'error':'invalid directory', 'path': str(p)}
    # keep listing local filesystem dirs only
    dirs=[]
    try:
        for c in sorted(p.iterdir(), key=lambda x: x.name.lower()):
            if c.is_dir():
                dirs.append({'name': c.name, 'path': str(c)})
    except Exception as e:
        return {'error': str(e), 'path': str(p)}
    parent = str(p.parent) if p.parent != p else str(p)
    return {'path': str(p), 'parent': parent, 'dirs': dirs[:500]}


@app.get('/setup/status')
def setup_status():
    cfg = get_config()
    reg = cfg.get('registry', {})
    approved = reg.get('approvedProjects', [])
    done = bool(approved and approved != ['/workspace'])
    return {'setupComplete': done, 'workspaceRoot': cfg.get('watch',{}).get('workspaceRoot','/workspace'), 'approvedProjects': approved}

@app.post('/setup/init')
def setup_init(path:str):
    set_workspace_root(path)
    add_project(path)
    return {'ok': True, 'path': path}


@app.get('/system/check')
def system_check():
    import os
    checks = {
      'health': True,
      'envFilePresent': os.path.exists('/app/backend/.env.local'),
      'watchConfigPresent': os.path.exists('/app/backend/watchers/watch_config.json'),
      'registryPresent': os.path.exists('/app/backend/watchers/project_registry.json')
    }
    checks['ok'] = all([checks['health'], checks['watchConfigPresent'], checks['registryPresent']])
    return checks


@app.post('/preview/diff')
def preview_diff(path:str):
    root = find_repo_root(path)
    if not root:
        return {'error':'no git repo root found', 'path': path}
    import subprocess
    diff = subprocess.check_output(['git','-C',str(root),'diff','-U3'], text=True, errors='ignore')
    files=[]
    cur=None
    added=removed=0
    for ln in diff.splitlines():
        if ln.startswith('diff --git '):
            parts=ln.split(' ')
            cur=parts[-1].replace('b/','') if parts else None
            if cur: files.append({'file':cur,'added':0,'removed':0})
        elif ln.startswith('+') and not ln.startswith('+++'):
            added += 1
            if files: files[-1]['added'] += 1
        elif ln.startswith('-') and not ln.startswith('---'):
            removed += 1
            if files: files[-1]['removed'] += 1
    frontend = [f for f in files if any(f['file'].endswith(x) for x in ['.html','.css','.js','.ts'])]
    backend = [f for f in files if any(f['file'].endswith(x) for x in ['.py','.go','.java','.cs','.php','.rb'])]
    return {
      'project': str(root),
      'summary': {'filesChanged': len(files), 'linesAdded': added, 'linesRemoved': removed},
      'impact': {'frontendFiles': len(frontend), 'backendFiles': len(backend)},
      'files': files[:200],
      'diffPreview': diff[:20000]
    }

@app.post('/preview/test-run')
def preview_test_run(path:str):
    root = find_repo_root(path)
    if not root:
        return {'error':'no git repo root found', 'path': path}
    import subprocess
    # safe lightweight probe: detect test command candidates only
    cmds=[]
    if (root/'package.json').exists(): cmds.append('npm test -- --help')
    if (root/'pytest.ini').exists() or any((root/x).exists() for x in ['tests','test']): cmds.append('pytest -q --collect-only')
    return {'project':str(root),'suggestedCommands':cmds,'note':'No tests executed automatically in preview mode.'}
