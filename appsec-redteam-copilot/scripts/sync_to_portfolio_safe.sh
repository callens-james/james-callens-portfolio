#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT_REPO="/home/james/openclaw-workspace/github-upload-temp/repo"
SUBDIR="appsec-redteam-copilot"

cd "$APP_DIR"
# push standalone first
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git push origin "$BRANCH"

# mirror with strict excludes
rsync -a --delete \
  --exclude '.git' \
  --exclude 'backend/.venv' \
  --exclude 'backend/data_reports.jsonl' \
  --exclude 'backend/watchers/change_queue.jsonl' \
  --exclude 'backend/data/eval_tmp' \
  --exclude 'backend/data/eval_reports' \
  --exclude 'backend/data/advisories_cache.json' \
  "$APP_DIR/" "$PORT_REPO/$SUBDIR/"

cd "$PORT_REPO"
git add "$SUBDIR"
if git diff --cached --quiet; then
  echo "No portfolio changes to commit."
else
  git commit -m "Sync AppSec Copilot from standalone (safe excludes)"
  git push origin main
fi
