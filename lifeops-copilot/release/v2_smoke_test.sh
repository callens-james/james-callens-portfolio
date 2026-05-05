#!/usr/bin/env bash
set -e
BASE=http://127.0.0.1:3360/api
for p in health modules queue/today career/apps career/analytics smb/weekly-brief healthcases/digest export/common v2/release-readiness; do
 code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/$p")
 echo "$p -> $code"
done
