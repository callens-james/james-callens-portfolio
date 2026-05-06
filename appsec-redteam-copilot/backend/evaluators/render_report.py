from datetime import datetime

def badge(risk:str):
    m = {'high':'🔴 HIGH','medium':'🟠 MEDIUM','low':'🟢 LOW'}
    return m.get((risk or '').lower(), '⚪ UNKNOWN')


def render_markdown(report:dict)->str:
    lines=[]
    lines.append(f"# AppSec Red Team Copilot Report")
    lines.append("")
    lines.append(f"- Generated: {datetime.utcnow().isoformat()} UTC")
    lines.append(f"- Project: `{report.get('project','')}`")
    lines.append(f"- Summary: {report.get('summary','')}")
    lines.append(f"- Overall Risk: **{badge(report.get('risk','unknown'))}**")
    lines.append("")
    lines.append("## Findings")
    findings = report.get('findings',[])
    if not findings:
        lines.append("No findings.")
    for f in findings:
        lines.append(f"### `{f.get('path','')}`")
        lines.append(f"- Risk: **{badge(f.get('risk','unknown'))}**")
        lines.append(f"- Score: {f.get('score',0)} | Confidence: {f.get('confidence',0)}")
        if f.get('note'):
            lines.append(f"- Note: {f['note']}")
        fs=f.get('findings',[])
        if fs:
            lines.append("- Signals:")
            for s in fs:
                lines.append(f"  - `{s.get('type')}` ({s.get('severity')}): {s.get('detail')}")
        ev=f.get('evidence',[])
        if ev:
            lines.append("- Evidence:")
            for e in ev[:3]:
                lines.append(f"  - **{e.get('id')}** ({e.get('severity','unknown')}): {e.get('summary','')}  ")
                lines.append(f"    Ref: {e.get('ref','')}")
        lines.append("")

    lines.append("## Recommended Actions")
    lines.append("1. Review HIGH/MEDIUM findings first.")
    lines.append("2. Add or update tests for affected flows.")
    lines.append("3. Patch vulnerable dependencies and re-run analysis.")
    lines.append("4. Require human approval before merge when risk >= MEDIUM.")
    lines.append("")
    return '\n'.join(lines)
