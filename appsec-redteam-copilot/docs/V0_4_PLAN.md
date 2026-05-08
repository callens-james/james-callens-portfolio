# AppSec Red Team Copilot — v0.4 Plan

## Scope
1. PR comment integration
2. richer evidence ranking/retrieval
3. shell trap reliability hardening

## Implemented in this pass

### 1) PR comment integration (MVP)
- Added API endpoint: `GET /report/pr-comment`
- Produces a ready-to-paste Markdown PR security comment from latest report:
  - verdict + risk
  - project/source context
  - top findings summary list

### 2) Evidence ranking/retrieval
- Next increment (planned): weighted ranking by severity/confidence/recency/signal density.
- This pass keeps existing retrieval and exposes top findings cleanly in PR comment output for reviewer triage.

### 3) Shell trap reliability hardening
- Added `scripts/shell_trap_doctor.sh`
  - validates trap dependencies
  - flags legacy broken path (`/home/scripts/safe-run.sh`)
  - verifies whether trap block is installed
  - returns non-zero if remediation needed

## Quick checks
```bash
curl -s "http://127.0.0.1:3480/report/pr-comment" | jq .
bash scripts/shell_trap_doctor.sh
```
