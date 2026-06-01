#!/usr/bin/env bash
set -euo pipefail
PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PORT_REPO="${PORT_REPO:-../james-callens-portfolio}"
SUBDIR="$(basename "$PROJ_DIR")"

cd "$PROJ_DIR"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)

# push standalone first
git push origin "$BRANCH"

# mirror to portfolio with safety excludes
rsync -a --delete \
  --exclude '.git' \
  --exclude '.venv' \
  --exclude 'node_modules' \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  --exclude '*.log' \
  --exclude '.env.local' \
  --exclude '.env' \
  "$PROJ_DIR/" "$PORT_REPO/$SUBDIR/"

cd "$PORT_REPO"
git add "$SUBDIR"
if git diff --cached --quiet; then
  echo "No portfolio changes to commit."
else
  git commit -m "Sync $SUBDIR from standalone (safe excludes)"
  git push origin main
  echo "Portfolio sync pushed."
fi
