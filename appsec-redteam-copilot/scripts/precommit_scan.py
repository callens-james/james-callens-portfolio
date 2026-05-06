#!/usr/bin/env python3
import sys, requests

API='http://127.0.0.1:3480'
PATH='/home/james/openclaw-workspace/appsec-redteam-copilot/backend/api/main.py'

def main():
    try:
        r=requests.post(f"{API}/analyze-diff-hunks", params={'path': PATH}, timeout=30)
        j=r.json()
    except Exception as e:
        print(f"[precommit] ERROR contacting API: {e}")
        return 2
    if 'error' in j:
        print(f"[precommit] ERROR: {j['error']}")
        return 2
    verdict=(j.get('verdict') or 'allow').lower()
    risk=j.get('risk','low')
    print(f"[precommit] risk={risk} verdict={verdict} findings={len(j.get('findings',[]))}")
    if verdict=='block':
        print('[precommit] BLOCK: high risk findings detected. Commit aborted.')
        return 1
    if verdict=='warn':
        print('[precommit] WARN: medium risk findings detected. Proceed with caution.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
