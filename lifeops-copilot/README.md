# LifeOps Copilot (v0.2.0-demo)

Local-first autopilot for life + work operations.

## What it does
- Ingests tasks/forms/notices into a unified inbox
- Detects deadlines, risk, and document type
- Generates checklists and suggested next actions
- Tracks approvals, rollback, audit timeline
- Includes Opportunity Navigator with explainable eligibility scoring
- Produces unified queue, daily plan, digest, and impact metrics

## Platforms
Target: **Windows, macOS, Linux**

## Optional integrations
- Core only (default)
- Core + Local AI (lite/balanced/quality model manager)
- Core + OpenClaw integration

## Run
```bash
npm install
npm run dev
```
Open: `http://<server-ip>:3360/`

## Demo flow
1. Click **Run Quick Start Demo**
2. Review Unified Today Queue
3. Open Confirmation Center (high-risk approvals)
4. Generate Plan My Day
5. Export bundle + metrics


## Installable Artifacts (Linux)
Built artifacts are available under `release/artifacts/`:
- `LifeOps Copilot_0.3.0_amd64.deb`
- `LifeOps Copilot-0.3.0-1.x86_64.rpm`
- `LifeOps Copilot_0.3.0_amd64.AppImage`
- `SHA256SUMS.txt`

### Quick install
- Debian/Ubuntu: `sudo apt install ./LifeOps\ Copilot_0.3.0_amd64.deb`
- RPM: `sudo rpm -i ./LifeOps\ Copilot-0.3.0-1.x86_64.rpm`
- AppImage: `chmod +x ./LifeOps\ Copilot_0.3.0_amd64.AppImage && ./LifeOps\ Copilot_0.3.0_amd64.AppImage`
