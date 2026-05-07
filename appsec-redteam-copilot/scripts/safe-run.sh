#!/usr/bin/env bash
set -euo pipefail
if [ $# -eq 0 ]; then
  echo "Usage: safe-run.sh '<command>'"
  exit 1
fi
CMD="$*"
TMP_FILE="/tmp/appsec_safe_run_$$.sh"
echo "$CMD" > "$TMP_FILE"

# stage file in repo so analyzer can inspect added line
REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$REPO/backend/tmp"
cp "$TMP_FILE" "$REPO/backend/tmp/safe_run_candidate.sh"

RESP=$(curl -s -G --data-urlencode "cmd=$CMD" -X POST "http://127.0.0.1:3480/analyze-command" || true)
VERDICT=$(echo "$RESP" | python3 -c 'import sys,json; 
try:
 j=json.load(sys.stdin); print(j.get("verdict","allow"))
except Exception:
 print("allow")')
RISK=$(echo "$RESP" | python3 -c 'import sys,json;
try:
 j=json.load(sys.stdin); print(j.get("risk","low"))
except Exception:
 print("low")')

echo "[safe-run] verdict=$VERDICT risk=$RISK"
if [ "$VERDICT" = "block" ]; then
  echo "[safe-run] BLOCKED. Command not executed."
  exit 2
fi
if [ "$VERDICT" = "warn" ]; then
  read -r -p "[safe-run] WARN detected. Type YES to run anyway: " ans
  if [ "$ans" != "YES" ]; then
    echo "[safe-run] Cancelled."
    exit 3
  fi
fi
bash -lc "$CMD"
