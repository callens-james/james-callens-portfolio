#!/usr/bin/env bash
set -e
cd /home/james/openclaw-workspace/appsec-redteam-copilot

echo "[demo] ensure API is running on :3480"

echo "[demo] create risky change"
echo "os.system(user_input)" >> backend/api/main.py
python3 scripts/precommit_scan.py || true

echo "[demo] revert risky line"
git checkout -- backend/api/main.py

echo "[demo] create safe change"
echo "# safe comment" >> backend/api/main.py
python3 scripts/precommit_scan.py || true

echo "[demo] done"
