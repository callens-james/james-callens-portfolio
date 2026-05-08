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

RESP=$(curl -s -G --data-urlencode "cmd=$CMD" -X POST "http://127.0.0.1:3480/broker/check" || true)
VERDICT=$(echo "$RESP" | python3 -c 'import sys,json; 
try:
 j=json.load(sys.stdin); print(j.get("policy",{}).get("verdict","allow"))
except Exception:
 print("allow")')
RISK=$(echo "$RESP" | python3 -c 'import sys,json;
try:
 j=json.load(sys.stdin); print(j.get("policy",{}).get("risk","low"))
except Exception:
 print("low")')

NEEDS_CONFIRM=$(echo "$RESP" | python3 -c 'import sys,json
try:
 j=json.load(sys.stdin); print(str(j.get("needsPrompt", False)).lower())
except Exception:
 print("false")')
TYPED_CONFIRM=$(echo "$RESP" | python3 -c 'import sys,json
try:
 j=json.load(sys.stdin); print(str(j.get("policy",{}).get("typedConfirm", False)).lower())
except Exception:
 print("false")')

echo "[safe-run] verdict=$VERDICT risk=$RISK"
if [ "$VERDICT" = "block" ]; then
  echo "[safe-run] BLOCKED. Command not executed."
  exit 2
fi
if [ "$VERDICT" = "warn" ] || [ "$NEEDS_CONFIRM" = "true" ]; then
  if [ "$TYPED_CONFIRM" = "true" ]; then
    read -r -p "[safe-run] HIGH-IMPACT ACTION. Type CONFIRM DELETE to proceed: " ans
    if [ "$ans" != "CONFIRM DELETE" ]; then
      echo "[safe-run] Cancelled."
      exit 3
    fi
  else
    read -r -p "[safe-run] WARN detected. Type YES to run anyway: " ans
    if [ "$ans" != "YES" ]; then
      echo "[safe-run] Cancelled."
      exit 3
    fi
  fi
fi
TOKEN=$(echo "$RESP" | python3 -c 'import sys,json
try:
 j=json.load(sys.stdin); print(j.get("approvalToken",""))
except Exception:
 print("")')
if [ -n "$TOKEN" ]; then
  APPROVE=$(curl -s -G --data-urlencode "token=$TOKEN" --data-urlencode "cmd=$CMD" --data-urlencode "ttl=300" -X POST "http://127.0.0.1:3480/safety/gate/approve" || true)
fi
EXEC=$(curl -s -G --data-urlencode "cmd=$CMD" --data-urlencode "token=$TOKEN" -X POST "http://127.0.0.1:3480/broker/exec" || true)
OK=$(echo "$EXEC" | python3 -c 'import sys,json
try:
 j=json.load(sys.stdin); print(str(j.get("ok",False)).lower())
except Exception:
 print("false")')
if [ "$OK" != "true" ]; then
  echo "[safe-run] execution failed or denied"
  echo "$EXEC"
  exit 4
fi
echo "$EXEC" | python3 -c 'import sys,json
try:
 j=json.load(sys.stdin); print(j.get("stdout","")[-2000:])
 e=j.get("stderr","")
 if e: print(e[-2000:])
except Exception:
 pass'
