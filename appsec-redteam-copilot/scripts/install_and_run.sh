#!/usr/bin/env bash
set -euo pipefail
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Install docker.io + docker compose plugin first." >&2
  exit 1
fi
cd "$(dirname "$0")/.."
docker compose up --build -d
echo "AppSec Copilot running at: http://127.0.0.1:3480/dashboard"
