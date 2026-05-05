# Safe Automation Template

A reusable local-first starter for guarded automation.

## What it includes
- Guard decision endpoint
- Confirmation gate for risky actions
- Blocked action policy
- Audit log trail
- Preflight safety script
- Rollback script placeholder

## Run
```bash
npm install
npm run check
npm start
```
Open: `http://localhost:3347/health`

## Example
Evaluate request:
```bash
curl -s http://127.0.0.1:3347/guard/evaluate \
 -H 'content-type: application/json' \
 -d '{"task":"Delete old logs","action":"delete","tool":"shell"}'
```

Execute risky request (requires confirmation header):
```bash
curl -s http://127.0.0.1:3347/guard/execute \
 -H 'content-type: application/json' \
 -H 'x-confirm: yes' \
 -d '{"task":"Delete old logs","action":"delete","tool":"shell"}'
```
