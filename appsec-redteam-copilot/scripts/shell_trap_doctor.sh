#!/usr/bin/env bash
set -euo pipefail
RC="${1:-$HOME/.bashrc}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SAFE_RUN="$ROOT/scripts/safe-run.sh"

ok=true

echo "[doctor] rc file: $RC"
if [ ! -f "$RC" ]; then
  echo "[warn] rc file missing"
  ok=false
fi

if [ ! -x "$SAFE_RUN" ]; then
  echo "[warn] safe-run missing or not executable: $SAFE_RUN"
  ok=false
else
  echo "[ok] safe-run executable"
fi

if grep -q 'appsec-runsafe-trap' "$RC" 2>/dev/null; then
  echo "[ok] trap block present"
else
  echo "[info] trap block not installed"
fi

if grep -q '/home/scripts/safe-run.sh' "$RC" 2>/dev/null; then
  echo "[warn] legacy broken path detected: /home/scripts/safe-run.sh"
  ok=false
fi

if $ok; then
  echo "[doctor] PASS"
else
  echo "[doctor] ATTENTION NEEDED"
  exit 1
fi
