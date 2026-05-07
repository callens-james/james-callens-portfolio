#!/usr/bin/env bash
set -euo pipefail
echo "[preflight] checking docker..."
command -v docker >/dev/null || { echo "FAIL: docker not installed"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "FAIL: docker compose unavailable"; exit 1; }
echo "[preflight] checking daemon access..."
docker ps >/dev/null 2>&1 || { echo "FAIL: no docker daemon access (try: newgrp docker)"; exit 1; }
echo "[preflight] checking env file..."
[ -f backend/.env.local ] && echo "OK: backend/.env.local found" || echo "WARN: backend/.env.local missing (alerts disabled)"
echo "[preflight] done"
