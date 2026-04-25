#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[prepublish] running sensitive file/name checks..."

# 1) Filename/path patterns that should never be public
name_hits=$(find . \
  \( -type d \( -name .git -o -name node_modules \) -prune \) -o \
  -type f \( -iname '.env' -o -iname '*key*' -o -iname '*secret*' -o -iname '*token*' -o -iname '*.pem' -o -iname 'id_rsa*' -o -iname '*login*' -o -iname '*password*' \) \
  -print)

# 2) Content patterns that look like credentials/secrets
content_hits=$(grep -RInE "(OPENAI_API_KEY|SESSION_SECRET|AUTH_PASS|BEGIN (RSA|OPENSSH|PRIVATE) KEY|password\s*[:=]|token\s*[:=]|api[_-]?key\s*[:=]|sk-[A-Za-z0-9_-]{10,}|ghp_[A-Za-z0-9]{20,})" . \
  --exclude-dir=.git --exclude-dir=node_modules || true)
content_hits=$(printf "%s\n" "$content_hits" | grep -v "scripts/prepublish_check.sh" || true)

fail=0
if [[ -n "${name_hits}" ]]; then
  echo "[prepublish][FAIL] Sensitive filename/path matches found:"
  echo "$name_hits"
  fail=1
fi

if [[ -n "${content_hits}" ]]; then
  echo "[prepublish][FAIL] Sensitive content matches found:"
  echo "$content_hits"
  fail=1
fi

if [[ $fail -ne 0 ]]; then
  echo "[prepublish] BLOCKED: clean or redact sensitive data before publishing."
  exit 2
fi

echo "[prepublish] PASS: no sensitive matches detected."
