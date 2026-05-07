#!/usr/bin/env bash
set -euo pipefail
RC_FILE="${1:-$HOME/.bashrc}"
MARK_START="# >>> appsec-runsafe-trap >>>"
MARK_END="# <<< appsec-runsafe-trap <<<"

if [ ! -f "$RC_FILE" ]; then
  touch "$RC_FILE"
fi

# remove existing block
awk -v s="$MARK_START" -v e="$MARK_END" '
  $0==s{skip=1; next}
  $0==e{skip=0; next}
  !skip{print}
' "$RC_FILE" > "$RC_FILE.tmp"
mv "$RC_FILE.tmp" "$RC_FILE"

cat >> "$RC_FILE" <<'EOF'
# >>> appsec-runsafe-trap >>>
# Optional command guard: routes interactive commands through runsafe.
# Toggle off: export APPSEC_TRAP_ENABLED=0
# Bypass once: command somecmd args
if [ -z "${APPSEC_TRAP_ENABLED+x}" ]; then
  export APPSEC_TRAP_ENABLED=1
fi

# Avoid recursion / non-interactive shells
if [[ $- == *i* ]]; then
  runsafe() {
    bash /home/james/openclaw-workspace/appsec-redteam-copilot/scripts/safe-run.sh "$*"
  }

  appsec_guard() {
    [ "${APPSEC_TRAP_ENABLED}" = "1" ] || return 0
    local cmd="$BASH_COMMAND"

    # skip empty or internal commands
    [[ -z "$cmd" ]] && return 0
    [[ "$cmd" == appsec_guard* ]] && return 0
    [[ "$cmd" == "history"* ]] && return 0
    [[ "$cmd" == "fg"* || "$cmd" == "bg"* || "$cmd" == "jobs"* ]] && return 0
    [[ "$cmd" == "runsafe "* ]] && return 0

    # avoid guarding commands already prefixed with 'command'
    [[ "$cmd" == command\ * ]] && return 0

    # only guard top-level prompt commands, not pipeline internals
    if [ -n "${APPSEC_GUARD_ACTIVE:-}" ]; then
      return 0
    fi

    export APPSEC_GUARD_ACTIVE=1
    # Ask runsafe to evaluate command; if blocked/warn cancelled, abort by SIGINT
    bash /home/james/openclaw-workspace/appsec-redteam-copilot/scripts/safe-run.sh "$cmd" || {
      unset APPSEC_GUARD_ACTIVE
      kill -INT $$
      return 130
    }
    unset APPSEC_GUARD_ACTIVE
    # command already executed by runsafe, so stop original execution
    kill -INT $$
    return 130
  }

  trap 'appsec_guard' DEBUG
fi
# <<< appsec-runsafe-trap <<<
EOF

echo "Installed AppSec shell trap block into: $RC_FILE"
echo "Reload shell: source $RC_FILE"
