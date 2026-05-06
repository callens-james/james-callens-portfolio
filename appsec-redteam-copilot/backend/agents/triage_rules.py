from pathlib import Path
import re
from rag.evidence import find_evidence

SECRET_PATTERNS = [
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"ghp_[A-Za-z0-9]{20,}"),
    re.compile(r"github_pat_[A-Za-z0-9_\-]+"),
    re.compile(r'(?i)api[_-]?key\s*[=:]\s*[\'\"][^\'\"]+[\'\"]'),
]

INJECTION_HINTS = ["SELECT * FROM", "UNION SELECT", "exec(", "subprocess.Popen(", "os.system("]
AUTH_HINTS = ["auth", "token", "password", "jwt", "session", "oauth"]
IGNORE_BASENAMES = {"triage_rules.py"}

def _strip_comment_lines(txt:str):
    lines=[]
    for ln in txt.splitlines():
      s=ln.strip()
      if s.startswith('#') or s.startswith('//'):
          continue
      lines.append(ln)
    return '\n'.join(lines)

def triage_file(path:str):
    p = Path(path)
    findings=[]
    risk='low'
    score=0

    if p.name in IGNORE_BASENAMES:
        return {'path':path,'risk':'low','score':0,'confidence':0.6,'findings':[],'note':'ignored self-rule file'}

    if p.exists() and p.is_file():
        try:
            txt = p.read_text(errors='ignore')[:200000]
        except Exception:
            txt = ''

        body = _strip_comment_lines(txt)

        for rx in SECRET_PATTERNS:
            if rx.search(body):
                findings.append({'type':'secret_pattern','severity':'high','detail':rx.pattern})
                score += 50

        for h in INJECTION_HINTS:
            if h in body:
                findings.append({'type':'injection_hint','severity':'medium','detail':h})
                score += 20

        lower = body.lower()
        if any(h in lower for h in AUTH_HINTS):
            findings.append({'type':'auth_surface','severity':'info','detail':'auth-related terms found'})
            score += 5

    evidence = []
    if findings:
        evidence = find_evidence(body if 'body' in locals() else '', top_k=3)

    if score >= 50:
        risk='high'
    elif score >= 20:
        risk='medium'
    else:
        risk='low'

    confidence = 0.6
    if findings:
        confidence = min(0.95, 0.6 + 0.05*len(findings))

    return {'path':path,'risk':risk,'score':score,'confidence':round(confidence,2),'findings':findings,'evidence':evidence}


def triage_snippet(file_path:str, line:int, code:str):
    findings=[]
    score=0
    body = code or ''
    for rx in SECRET_PATTERNS:
        if rx.search(body):
            findings.append({'type':'secret_pattern','severity':'high','detail':rx.pattern})
            score += 50
    for h in INJECTION_HINTS:
        if h in body:
            findings.append({'type':'injection_hint','severity':'medium','detail':h})
            score += 20
    lower = body.lower()
    if any(h in lower for h in AUTH_HINTS):
        findings.append({'type':'auth_surface','severity':'info','detail':'auth-related terms found'})
        score += 5

    risk='low'
    if score >= 50: risk='high'
    elif score >= 20: risk='medium'

    evidence=[]
    if findings:
        evidence = find_evidence(body, top_k=3)

    return {'path':file_path,'line':line,'added':code,'risk':risk,'score':score,'findings':findings,'evidence':evidence}
