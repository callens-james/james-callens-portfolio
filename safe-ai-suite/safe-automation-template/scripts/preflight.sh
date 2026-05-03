#!/usr/bin/env bash
set -euo pipefail

echo "[preflight] checking policy file..."
test -f config/policy.json

echo "[preflight] checking blocked actions present..."
grep -q "blockedActions" config/policy.json

echo "[preflight] checking local-first mode..."
grep -q '"localFirst": true' config/policy.json

echo "[preflight] OK"
