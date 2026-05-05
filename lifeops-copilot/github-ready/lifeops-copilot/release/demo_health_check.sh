#!/usr/bin/env bash
set -e
BASE=http://127.0.0.1:3360/api
for p in health queue/today digest/daily plan/day metrics/local opportunities notifications version; do
 code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/$p")
 echo "$p -> $code"
done
