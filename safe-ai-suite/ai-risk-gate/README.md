# AI Risk Gate (MVP)

A local-first policy gate that evaluates task/tool/action combinations and returns:
- risk level (low/medium/high)
- score
- reasons
- requiresConfirmation

## Run
```bash
npm install
npm start
```
Open: http://localhost:3344

## API
POST `/api/evaluate`
```json
{
  "task": "Delete logs and restart service",
  "tool": "shell",
  "action": "restart-service"
}
```

## Notes
- Rules are in `config/policy.json`
- Audit log is appended to `logs/decisions.jsonl`
- This is intended as a reusable safety component for agent workflows.
