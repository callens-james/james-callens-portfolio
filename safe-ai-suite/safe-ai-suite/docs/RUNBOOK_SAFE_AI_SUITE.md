# Runbook — Safe AI Suite

## Prerequisites
- Node.js 20+
- npm
- Local network access to server ports 3344, 3345, 3346, 3347

## 1) AI Risk Gate
```bash
cd "<repo-root>/ai-risk-gate"
npm install
npm start
```
Open: `http://<server-ip>:3344`

## 2) Timeline Viewer
```bash
cd "<repo-root>/timeline-viewer"
npm install
npm start
```
Open: `http://<server-ip>:3345`

## 3) Eval Harness
```bash
cd "<repo-root>/eval-harness"
npm install
npm start
```
Open: `http://<server-ip>:3346`

### Batch run only
```bash
cd "<repo-root>/eval-harness"
npm run run:batch
```

## 4) Safe Automation Template
```bash
cd "<repo-root>/safe-automation-template"
npm install
npm run check
npm start
```
Open: `http://<server-ip>:3347/health`

## Weekly Refresh (single command)
```bash
cd "<workspace-root>"
./run_weekly_safe_ai.sh
```

## Publish Safety Gate
```bash
cd "<repo-root>"
./prepublish_check.sh
```
