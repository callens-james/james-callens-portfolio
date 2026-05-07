# AppSec Red Team Copilot

Background security copilot for coding workflows.

## MVP v1
- Watch selected project folders for code/config/dependency changes
- Build change-set/diff summary
- Run triage (rules + LLM-ready hook)
- Retrieve security evidence (RAG stub)
- Output PR-style security report
- Human-approval only

## Run
```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn api.main:app --reload --port 3480
```

## Watcher config
Edit `backend/watchers/watch_config.json`.


## Step 9: Pre-commit Gate + Demo

### Install hooks
```bash
cd /home/james/openclaw-workspace/appsec-redteam-copilot
bash scripts/install_hooks.sh
```

### Pre-commit scan (manual)
```bash
python3 scripts/precommit_scan.py
```

### 2-minute demo
```bash
bash scripts/demo_run.sh
```

Behavior:
- `allow` => exit 0
- `warn` => exit 0 with warning
- `block` => exit 1 (commit blocked)


## Docker Quick Start

```bash
cd /home/james/openclaw-workspace/appsec-redteam-copilot
docker compose up --build
```

Open dashboard:
- http://127.0.0.1:3480/dashboard
- http://<server-ip>:3480/dashboard

Stop:
```bash
docker compose down
```


## Why This Matters (AI Engineering Recruiter View)

AppSec Red Team Copilot demonstrates production-oriented AI engineering patterns beyond API wrapping:
- **Pre-change security analysis** on git diff hunks (added lines) with merge-gate verdicts (`allow`/`warn`/`block`)
- **Post-change analysis** and persisted report history
- **Evidence-backed findings** via seeded + live advisory ingestion cache
- **Evaluation harness** with measurable metrics (`riskAccuracy`, `typeCoverage`)
- **Operational deployment** via Docker Compose with separate API + watcher services

### Core Endpoints
- `/analyze-diff-hunks` (pre-change)
- `/analyze-repo-diff` (repo diff)
- `/reports` (history)
- `/advisories/refresh` (evidence cache)
- `/eval/run` (quality benchmark)
- `/dashboard` (operator UI)


## Screenshots

### Dashboard Overview
![Dashboard Overview](docs/screenshots/dashboard-overview.jpg)

### Pre-change Findings (Verdict + Signals)
![Pre-change Findings](docs/screenshots/prechange-findings.jpg)

### Findings Table Detail
![Findings Table](docs/screenshots/prechange-table.jpg)


## Alerts Setup
See `docs/ALERTS_SETUP.md` for Telegram alert configuration and troubleshooting.


## Optional Auto-Guard Shell Trap
For automatic interactive command interception through AppSec, see `docs/SHELL_TRAP_SETUP.md`.
