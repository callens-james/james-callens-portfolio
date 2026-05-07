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


## Usage Guide

### 1) Start with Docker (recommended)
```bash
docker compose up --build
```

Open dashboard:
- `http://127.0.0.1:3480/dashboard`
- `http://<server-ip>:3480/dashboard`

### 2) Pre-change security scan (git diff hunks)
Use dashboard button **Analyze Pre-Change Hunks** or CLI:
```bash
curl -s -X POST "http://127.0.0.1:3480/analyze-diff-hunks?path=/home/james/openclaw-workspace/appsec-redteam-copilot/backend/api/main.py" | jq
```

### 3) Verdict semantics
- `allow` → low risk
- `warn` → medium risk, human review recommended
- `block` → high risk, do not merge without remediation

### 4) Refresh advisory evidence cache
```bash
curl -s -X POST "http://127.0.0.1:3480/advisories/refresh?limit=30" | jq
```

### 5) Run evaluation harness
```bash
curl -s -X POST "http://127.0.0.1:3480/eval/run" | jq
```

### 6) Generate markdown security report
```bash
curl -s -X POST "http://127.0.0.1:3480/report/markdown?path=/home/james/openclaw-workspace/appsec-redteam-copilot/backend/api/main.py" | jq
```

## Legal

### License
This project is licensed under **AGPL-3.0-only**.
See `LICENSE`.

### Notice
See `NOTICE` for copyright and attribution.

### Security/Compliance Disclaimer
This tool provides automated security assistance and evidence ranking.
It does **not** guarantee absence of vulnerabilities and does not replace formal security review.
Human approval is required for medium/high-risk actions.


## Installable (Docker-first)

One-command local install/run:
```bash
bash scripts/install_and_run.sh
```

Stop services:
```bash
docker compose down
```


## Quick Install / Run

```bash
# clone repo
git clone https://github.com/callens-james/james-callens-portfolio.git
cd appsec-redteam-copilot

# preferred: Docker
docker compose up --build
```

If Docker is not available, see project-specific local run instructions in this README.
