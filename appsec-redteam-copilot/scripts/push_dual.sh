#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT_REPO="/home/james/openclaw-workspace/github-upload-temp/repo"
SUBDIR="appsec-redteam-copilot"

cd "$APP_DIR"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "[1/3] Push standalone ($BRANCH)"
git push standalone "$BRANCH"

echo "[2/3] Sync into portfolio mirror"
rsync -a --delete --exclude '.git' "$APP_DIR/" "$PORT_REPO/$SUBDIR/"

cd "$PORT_REPO"
git add "$SUBDIR"
if git diff --cached --quiet; then
  echo "[3/3] No portfolio changes to commit"
else
  git commit -m "Sync AppSec Red Team Copilot from standalone repo"
  git push origin main
  echo "[3/3] Portfolio synced and pushed"
fi
