#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Install Docker first, then rerun." >&2
  exit 1
fi

echo "Starting AppSec Copilot..."

# Auto-create local env file for first-time users
if [ ! -f backend/.env.local ]; then
  if [ -f backend/.env.example ]; then
    cp backend/.env.example backend/.env.local
    echo "Created backend/.env.local from .env.example (edit for real alerts if desired)."
  else
    touch backend/.env.local
    echo "Created empty backend/.env.local"
  fi
fi
docker compose up --build -d

echo "Waiting for health..."
for i in {1..30}; do
  if curl -sf http://127.0.0.1:3480/health >/dev/null; then
    echo "✅ AppSec Copilot is live: http://127.0.0.1:3480/dashboard"
    echo "Shell trap is optional (recommended only after validation)."
echo "Enable: bash scripts/install_shell_trap.sh ~/.bashrc"
echo "Disable: bash scripts/toggle_shell_trap.sh off"
echo "Next: open dashboard, run First-Run Setup, set your project path."
    exit 0
  fi
  sleep 1
done

echo "⚠ App started but health check failed. Run: docker compose logs --tail=120 appsec-copilot"
exit 2
