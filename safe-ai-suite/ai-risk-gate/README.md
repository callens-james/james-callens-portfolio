# AI Risk Gate

AI Risk Gate is a local-first policy gate for classifying task/tool/action combinations before automation runs.

## What it returns

- risk level: `low`, `medium`, or `high`
- numeric score
- human-readable reasons
- `requiresConfirmation` for actions that need explicit approval

## Run

```bash
npm install
npm start
```

Open: `http://localhost:3344`

## API

`POST /api/evaluate`

```json
{
  "task": "Delete logs and restart service",
  "tool": "shell",
  "action": "restart-service"
}
```

## Configuration

Rules live in `config/policy.json`. Use the included policy as a starter and adapt thresholds, blocked actions, and confirmation terms for your own workflow.

## Evidence

Decisions are appended to `logs/decisions.jsonl` so reviewers can inspect what was allowed, blocked, or escalated.

## Scope

This is a reusable safety component for local agent workflows. It is not a complete authorization system or production security boundary by itself.
