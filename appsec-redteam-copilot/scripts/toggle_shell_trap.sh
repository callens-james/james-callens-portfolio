#!/usr/bin/env bash
set -euo pipefail
MODE="${1:-status}"
RC_FILE="${2:-$HOME/.bashrc}"

case "$MODE" in
  on)
    if grep -q "APPSEC_TRAP_ENABLED" "$RC_FILE"; then
      sed -i "s/export APPSEC_TRAP_ENABLED=.*/export APPSEC_TRAP_ENABLED=1/" "$RC_FILE"
    else
      echo "export APPSEC_TRAP_ENABLED=1" >> "$RC_FILE"
    fi
    echo "Shell trap set to ON in $RC_FILE"
    ;;
  off)
    if grep -q "APPSEC_TRAP_ENABLED" "$RC_FILE"; then
      sed -i "s/export APPSEC_TRAP_ENABLED=.*/export APPSEC_TRAP_ENABLED=0/" "$RC_FILE"
    else
      echo "export APPSEC_TRAP_ENABLED=0" >> "$RC_FILE"
    fi
    echo "Shell trap set to OFF in $RC_FILE"
    ;;
  status)
    grep -n "APPSEC_TRAP_ENABLED" "$RC_FILE" || echo "No explicit APPSEC_TRAP_ENABLED line found (default from trap block applies)."
    ;;
  *)
    echo "Usage: $0 [on|off|status] [rc_file]"; exit 1;;
esac

echo "Reload shell: source $RC_FILE"
