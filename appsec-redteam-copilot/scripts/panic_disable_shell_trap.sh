#!/usr/bin/env bash
set -euo pipefail
for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
  [ -f "$f" ] || continue
  sed -i '/# >>> appsec-runsafe-trap >>>/,/# <<< appsec-runsafe-trap <<</d' "$f"
  sed -i '/safe-run.sh/d;/APPSEC_TRAP_ENABLED/d;/appsec_guard/d' "$f"
done
echo "Shell trap disabled. Open a new terminal."
