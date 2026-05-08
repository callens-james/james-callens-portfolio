#!/usr/bin/env bash
set -euo pipefail
BASE=${BASE:-http://127.0.0.1:3360/api}
HOST_CHECK=${BASE%/api}/api/health

if ! curl -fsS "$HOST_CHECK" >/dev/null 2>&1; then
  echo "[health-check] API unreachable at $HOST_CHECK"
  echo "[health-check] Start LifeOps first, then rerun this script."
  echo "[health-check] Tip: verify local service is listening on port 3360."
  exit 2
fi

fail=0
for p in health queue/today digest/daily plan/day metrics/local opportunities notifications version; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/$p" || true)
  echo "$p -> $code"
  if [[ "$code" != "200" ]]; then
    fail=1
  fi
done

if [[ $fail -ne 0 ]]; then
  echo "[health-check] One or more endpoints failed."
  exit 1
fi

echo "[health-check] All demo endpoints healthy."
