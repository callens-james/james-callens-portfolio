#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Install Docker first, then rerun." >&2
  exit 1
fi

echo "Starting AppSec Copilot..."
docker compose up --build -d

echo "Waiting for health..."
for i in {1..30}; do
  if curl -sf http://127.0.0.1:3480/health >/dev/null; then
    if [ -f scripts/install_shell_trap.sh ]; then
  bash scripts/install_shell_trap.sh ~/.bashrc >/dev/null 2>&1 || true
fi

echo "✅ AppSec Copilot is live: http://127.0.0.1:3480/dashboard"
    echo "Shell trap installed by default (can toggle): bash scripts/toggle_shell_trap.sh off"
echo "Next: open dashboard, run First-Run Setup, set your project path."
    exit 0
  fi
  sleep 1
done

echo "⚠ App started but health check failed. Run: docker compose logs --tail=120 appsec-copilot"
exit 2
