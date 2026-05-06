#!/usr/bin/env bash
set -e
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit scripts/precommit_scan.py
printf "Installed git hooks path: %s
" "$(git config core.hooksPath)"
