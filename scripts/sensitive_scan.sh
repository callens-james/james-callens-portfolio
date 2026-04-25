#!/usr/bin/env bash
set -euo pipefail

echo "[secret-scan] quick filename scan"
find . \
  \( -type d \( -name .git -o -name node_modules \) -prune \) -o \
  -type f \( -iname '.env' -o -iname '*key*' -o -iname '*secret*' -o -iname '*token*' -o -iname '*.pem' -o -iname 'id_rsa*' \) \
  -print

echo "[secret-scan] done"
