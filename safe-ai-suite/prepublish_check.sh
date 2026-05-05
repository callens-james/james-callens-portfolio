#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "[check] scanning for sensitive patterns under: $ROOT"
FAIL=0

PATTERNS=(
 'github_pat_[A-Za-z0-9_]+'
 'ghp_[A-Za-z0-9]+'
 'sk-[A-Za-z0-9_-]{20,}'
 'AKIA[0-9A-Z]{16}'
 '-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----'
 '(?i)(password|passwd|secret|token|api[_-]?key)\s*[:=]\s*[^\s]+'
)
for p in "${PATTERNS[@]}"; do
 if grep -RInE --exclude-dir=node_modules --exclude-dir=.git --exclude='*.lock' "$p" . >/tmp/prepub_hits.txt 2>/dev/null; then
 if [ -s /tmp/prepub_hits.txt ]; then
 echo "[warn] potential sensitive match for pattern: $p"
 sed -n '1,20p' /tmp/prepub_hits.txt
 FAIL=1
 fi
 fi
done

# Size warnings
while IFS= read -r f; do
 size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo 0)
 if [ "$size" -gt 25000000 ]; then echo "[warn] >25MB: $f"; FAIL=1; fi
 if [ "$size" -gt 100000000 ]; then echo "[warn] >100MB: $f"; FAIL=1; fi
done < <(find . -type f)

# Screenshot checks
IMG_LIST=$(find . -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \))
if [ -n "$IMG_LIST" ]; then
 echo "[check] image files detected:"
 echo "$IMG_LIST" | sed -n '1,200p'

 # filename/path risk terms
 if echo "$IMG_LIST" | grep -Ei '(token|secret|password|key|credential|pat)' >/tmp/prepub_img_warn.txt; then
 if [ -s /tmp/prepub_img_warn.txt ]; then
 echo "[warn] risky image filename/path detected:"
 cat /tmp/prepub_img_warn.txt
 FAIL=1
 fi
 fi

 # OCR scan when available
 if command -v tesseract >/dev/null 2>&1; then
 echo "[check] running OCR scan on images (tesseract) ..."
 while IFS= read -r img; do
 [ -z "$img" ] && continue
 txt=$(tesseract "$img" stdout 2>/dev/null | tr -d '\r' || true)
 if echo "$txt" | grep -Eiq '(github_pat_[A-Za-z0-9_]+|ghp_[A-Za-z0-9]+|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----|[A-Za-z0-9_\-]{32,})'; then
 echo "[warn] OCR found sensitive-looking text in: $img"
 FAIL=1
 fi
 done <<< "$IMG_LIST"
 else
 echo "[warn] tesseract not installed; OCR scan skipped for screenshots."
 FAIL=1
 fi
fi

if [ "$FAIL" -eq 1 ]; then
 echo "\n[result] FAILED prepublish check. Resolve warnings before pushing."
 exit 1
fi

echo "[result] PASS prepublish check."
