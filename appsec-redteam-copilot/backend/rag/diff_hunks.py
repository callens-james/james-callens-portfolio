from pathlib import Path
import subprocess
import re

HUNK_RE = re.compile(r'^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')

def get_unified_diff(repo_root:Path):
    try:
        return subprocess.check_output(['git','-C',str(repo_root),'diff','-U3'], text=True, errors='ignore')
    except Exception:
        return ''

def parse_added_hunks(diff_text:str):
    results=[]
    cur_file=None
    new_line=0
    for ln in diff_text.splitlines():
        if ln.startswith('+++ b/'):
            cur_file = ln[6:]
            continue
        m=HUNK_RE.match(ln)
        if m:
            new_line=int(m.group(1))
            continue
        if ln.startswith('+') and not ln.startswith('+++') and cur_file:
            results.append({'file':cur_file,'line':new_line,'added':ln[1:]})
            new_line += 1
        elif ln.startswith('-') and not ln.startswith('---'):
            pass
        else:
            if cur_file and not ln.startswith('diff --git'):
                new_line += 1
    return results
