#!/usr/bin/env bash
set -euo pipefail
curl -sf http://127.0.0.1:3480/health >/dev/null && echo "OK: health" || { echo "FAIL: health"; exit 1; }
code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3480/dashboard)
[ "$code" = "200" ] && echo "OK: dashboard" || { echo "FAIL: dashboard status=$code"; exit 1; }
echo "OK: install verified"
