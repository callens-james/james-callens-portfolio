# LifeOps Copilot

Local-first autopilot for life + work operations.

Version: **v0.4.0-sprint4** (app)  
Release milestone: **v0.3.0-v2-demo-final**

---

## What this is
LifeOps Copilot is a unified operations assistant for individuals and small teams. It combines:
- paperwork/task triage,
- opportunity tracking,
- career pipeline management,
- SMB operations tracking,
- health bureaucracy workflows,
- trust/safety controls,
- auditability and exportability.

It is designed to run locally and stay usable on lower-resource machines.

---

## What to do with it (quick start)
1. Launch the app.
2. Click **Run Quick Start Demo**.
3. Review:
   - Unified Today Queue
   - Plan My Day
   - Confirmation Center
   - Digest + Impact
4. Use Setup Wizard to choose profile:
   - Core only
   - Core + Local AI
   - Core + OpenClaw integration
5. Save onboarding settings.

---

## Main sections and what they do

## 1) First-Time Setup / Setup Wizard
- Loads install profiles from installer profile spec.
- Applies selected profile to runtime settings.
- Enforces warning acknowledgment for optional integrations.
- Tracks setup completion and beginner mode.

## 2) Install Profile / Integrations
- Manual control for current integration profile.
- Toggle local AI / OpenClaw routing policy.
- Intended for post-install changes.

## 3) Model Manager
- Select model tier (lite/balanced/quality).
- Run compatibility checks against system resources.
- Apply model preference to settings.

## 4) Career Copilot
- Track job applications (company/role/source/status/follow-up).
- Auto fit scoring by role/notes keywords.
- Quick status updates (applied/interview/rejected).

## 5) Career Analytics + Reports
- Response rate and volume analytics.
- Weekly markdown report generation.
- CSV export for external tracking.
- Interview prep markdown per application.

## 6) SMB Console
- Invoice tracker (amount, due date, status).
- Compliance tracker (items, due dates, status).
- Vendor risk tracker (low/med/high) with notification hooks.
- Weekly SMB brief generation.

## 7) Health Bureaucracy Copilot
- Case tracker for claims / prior auth / referral / appeal.
- Deadline + priority handling.
- Checklist-driven case execution.
- Health digest summary.

## 8) Prioritized Items + Item Detail
- Unified paperwork/task list with risk and priority.
- State transitions (inbox -> parsed -> planned -> awaiting approval -> in progress -> done).
- Detail view shows:
  - detected type,
  - extraction confidence,
  - checklist,
  - recommended actions.

## 9) Approval / Trust Layer
- Pending approval center.
- High-risk action confirmation phrase required.
- Undo/revert paths.
- Rollback controls.

## 10) Unified Today Queue / Plan My Day
- Merges enabled module tasks into one ranked list.
- Suggests next best actions with reasons.
- Produces day plan text output.

## 11) Notifications + Scheduler
- Local scheduler for reminders.
- Quiet hours and interval controls.
- Notification inbox with mark-read/snooze.
- Proposal-only background behavior (no irreversible auto-actions).

## 12) Outcome + Impact
- Tracks completion and throughput metrics.
- Estimates manual vs assisted time impact.
- Configurable assumptions.

## 13) Case Studies + Scenarios + Demo Script
- Load scenario templates.
- Generate case-study markdown from live state.
- Built-in demo script helper.

## 14) Data Portability + Privacy
- Export package (redacted/full, include/exclude notes/audit).
- Import preview and apply with validation.
- Module-scoped or full data clear with confirm phrase.
- Integrity report (state version/checksum/counts).

## 15) Reliability
- Selfcheck endpoint view.
- Backup listing and restore.
- Versioned state migration.

## 16) Release + Config + Datasets
- Version display.
- Config export/import.
- Save/load named datasets.
- Export bundle artifacts.

## 17) Multi-User (local role simulation)
- Switch user context (owner/member/viewer).
- Role-gated permissions for sensitive actions.

---

## API highlights
- Health: `/api/health`, `/api/selfcheck`, `/api/perf`
- Core queue/planning: `/api/queue/today`, `/api/plan/day`, `/api/digest/daily`
- Security/trust: `/api/security`, `/api/actions/*`, `/api/timeline`
- Modules: `/api/career/*`, `/api/smb/*`, `/api/healthcases*`
- Portability: `/api/data/*`, `/api/config/*`, `/api/export/*`
- Installer/setup: `/api/installer/*`, `/api/onboarding`

---

## Build artifacts (current)

### Linux artifacts
Location:
`release/artifacts/`
- `LifeOps Copilot_0.3.0_amd64.deb`
- `LifeOps Copilot-0.3.0-1.x86_64.rpm`
- `LifeOps Copilot_0.3.0_amd64.AppImage`
- `SHA256SUMS.txt`

### Windows artifact
Location (Windows build host):
`...\tauri\src-tauri\target\release\bundle\msi\LifeOps Copilot_0.3.0_x64_en-US.msi`

---

## Run locally (dev)
```bash
cd /home/james/openclaw-workspace/lifeops-copilot
npm install
npm run dev
```
Open: `http://<server-ip>:3360/`

---

## Safety model
- Local-first by default
- Explicit confirmations for sensitive actions
- Redaction-first export options
- Audit trail + rollback support
- No mandatory paid AI dependency

---

## Suggested operator workflow
1. Setup Wizard (once)
2. Quick Start Demo (orientation)
3. Select modules for your use case
4. Add real data incrementally
5. Use queue + plan daily
6. Export reports/metrics weekly
7. Backup and integrity check periodically
