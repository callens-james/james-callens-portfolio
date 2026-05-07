# James Callens — AI Systems & Operations Portfolio

Practical, local-first AI engineering projects focused on real workflows, safety, and production readiness.

## Start Here
- **Flagship:** `appsec-redteam-copilot`
- Open this first: `appsec-redteam-copilot/README.md`
- Quick demo path: dashboard -> pre-change verdict -> eval -> markdown report


## Featured Projects

- **AppSec Red Team Copilot** — pre-change and post-change code-risk triage with verdict gates (`allow/warn/block`), advisory-backed evidence, eval harness, and Docker + service-mode ops.
  - Folder: [`appsec-redteam-copilot/`](./appsec-redteam-copilot)

- **LifeOps Copilot** — local-first life/work operations platform (paperwork, planning, approvals, reporting, exports, privacy controls).
  - Folder: [`lifeops-copilot/`](./lifeops-copilot)

- **Ops Insight Copilot (Analyst Workbench)** — analyst workflow system for KPI extraction, anomaly review, and action-oriented weekly briefs.
  - Folder: [`ops-insight-copilot-analyst-workbench/`](./ops-insight-copilot-analyst-workbench)

- **Safe AI Suite** — safety engineering toolkit with risk gating, traceability, and evaluation workflows.
  - Folder: [`safe-ai-suite/`](./safe-ai-suite)

## Additional Projects

- [`ai-toolkit/`](./ai-toolkit)
- [`workflow-studio/`](./workflow-studio)
- [`r-workflow-suite/`](./r-workflow-suite)
- [`weather-dashboard/`](./weather-dashboard)

## Project Pages / Docs

- Project index: [`projects/PROJECT_INDEX.md`](./projects/PROJECT_INDEX.md)
- Mission Control write-up: [`projects/ai-mission-control.md`](./projects/ai-mission-control.md)
- Job pipeline write-up: [`projects/job-pipeline.md`](./projects/job-pipeline.md)
- About: [`docs/ABOUT.md`](./docs/ABOUT.md)
- Architecture snapshot: [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md)

## Security & Publish Workflow

```bash
./scripts/prepublish_check.sh
./scripts/make_public_bundle.sh
```

## Hiring

- LinkedIn: <https://www.linkedin.com/in/james-callens-373a3087/>

## License

This portfolio and included projects are licensed under **AGPL-3.0-only** unless otherwise noted. See `LICENSE` and per-project `NOTICE` files.


## Flagship Preview (AppSec Red Team Copilot)

![AppSec Dashboard](assets/screenshots/appsec-dashboard-overview.jpg)

![Pre-change Findings](assets/screenshots/appsec-prechange-findings.jpg)

![Findings Table](assets/screenshots/appsec-prechange-table.jpg)

## 30-Second Demo Script
1. Open dashboard
2. Run pre-change analysis
3. Show verdict + findings
4. Run eval
5. Generate markdown report

## What this portfolio proves
- I build **governed AI systems**, not wrapper demos
- I use **evals + CI gates** to control quality
- I can operate services with **Docker/systemd**
- I apply **risk controls** and secret hygiene in production-like workflows

## Licensing note
Code is provided for portfolio demonstration and learning under project licenses (AGPL where specified).
