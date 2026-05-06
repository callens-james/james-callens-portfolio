import json
from pathlib import Path
from datetime import datetime
from agents.triage_rules import triage_file

BASE = Path(__file__).resolve().parents[1]
CASES = BASE / 'data' / 'eval_cases.json'
TMP = BASE / 'data' / 'eval_tmp'
OUT = BASE / 'data' / 'eval_reports'

TMP.mkdir(parents=True, exist_ok=True)
OUT.mkdir(parents=True, exist_ok=True)

def run_eval():
    cases = json.loads(CASES.read_text())
    rows=[]
    ok_risk=0
    ok_types=0

    for c in cases:
        fp = TMP / f"{c['id']}.py"
        fp.write_text(c['content'])
        r = triage_file(str(fp))
        got_types = sorted(set([f['type'] for f in r.get('findings',[])]))
        exp_types = sorted(set(c.get('expectedTypes',[])))
        risk_ok = (r.get('risk') == c.get('expectedRisk'))
        type_ok = all(t in got_types for t in exp_types)
        ok_risk += 1 if risk_ok else 0
        ok_types += 1 if type_ok else 0
        rows.append({
            'id': c['id'],
            'expectedRisk': c['expectedRisk'],
            'gotRisk': r.get('risk'),
            'riskPass': risk_ok,
            'expectedTypes': exp_types,
            'gotTypes': got_types,
            'typePass': type_ok,
            'score': r.get('score'),
            'confidence': r.get('confidence')
        })

    summary = {
        'ranAt': datetime.utcnow().isoformat(),
        'cases': len(cases),
        'riskAccuracy': round(ok_risk/len(cases), 3) if cases else 0,
        'typeCoverage': round(ok_types/len(cases), 3) if cases else 0,
        'rows': rows
    }

    out = OUT / f"eval-{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}.json"
    out.write_text(json.dumps(summary, indent=2))
    return summary, out

if __name__ == '__main__':
    summary, out = run_eval()
    print(json.dumps({'out': str(out), 'riskAccuracy': summary['riskAccuracy'], 'typeCoverage': summary['typeCoverage']}, indent=2))
