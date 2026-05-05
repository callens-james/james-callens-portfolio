#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/../"
OUT_ZIP="${OUT_DIR}/public-safe-bundle.zip"

"${ROOT_DIR}/scripts/prepublish_check.sh"

cd "$ROOT_DIR"
python3 - <<'PY'
from pathlib import Path
import zipfile
root = Path('.').resolve()
out = (root.parent / 'public-safe-bundle.zip').resolve()
allowed = [
 'README.md',
 '.gitignore',
 'docs/ABOUT.md',
 'docs/ARCHITECTURE.md',
 'projects/PROJECT_INDEX.md',
 'projects/ai-mission-control.md',
 'projects/job-pipeline.md',
 'assets/mission-control-main.jpg',
 'scripts/sensitive_scan.sh',
 'scripts/prepublish_check.sh',
]
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
 for rel in allowed:
 p = root / rel
 if p.exists() and p.is_file():
 z.write(p, Path('public-repo-scaffold')/rel)
print(out)
PY

echo "[bundle] created: ${OUT_ZIP}"
