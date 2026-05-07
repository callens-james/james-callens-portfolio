#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 1 ]; then
  echo "Usage: $0 /absolute/path/to/project-or-workspace"
  exit 1
fi
P="$1"
python3 - <<PY
from watchers.config_manager import set_workspace_root, add_project
p=r'''$P'''
set_workspace_root(p)
add_project(p)
print('Updated workspaceRoot and added approved project:', p)
PY
