# Runbook — Safe AI Suite

## Prerequisites
- Node.js 20+
- npm
- Local network access to server ports 3344, 3345, 3346, 3347

## 1) AI Risk Gate
```bash
cd "/home/james/openclaw-workspace/Safe AI/projects/ai-risk-gate"
npm install
npm start
```
Open: `http://<server-ip>:3344`

## 2) Timeline Viewer
```bash
cd "/home/james/openclaw-workspace/Safe AI/projects/timeline-viewer"
npm install
npm start
```
Open: `http://<server-ip>:3345`

## 3) Eval Harness
```bash
cd "/home/james/openclaw-workspace/Safe AI/projects/eval-harness"
npm install
npm start
```
Open: `http://<server-ip>:3346`

### Batch run only
```bash
cd "/home/james/openclaw-workspace/Safe AI/projects/eval-harness"
npm run run:batch
```

## 4) Safe Automation Template
```bash
cd "/home/james/openclaw-workspace/Safe AI/projects/safe-automation-template"
npm install
npm run check
npm start
```
Open: `http://<server-ip>:3347/health`

## Weekly Refresh (single command)
```bash
cd "/home/james/openclaw-workspace/Safe AI"
./run_weekly_safe_ai.sh
```

## Publish Safety Gate
```bash
cd "/home/james/openclaw-workspace/Safe AI/github-ready"
./prepublish_check.sh
```
