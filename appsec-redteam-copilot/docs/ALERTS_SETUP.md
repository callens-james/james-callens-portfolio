# Alerts Setup (Telegram)

## Goal
Enable automatic Telegram alerts for AppSec verdicts (`warn` / `block`) without storing secrets in git.

## 1) Local-only secret file
Create:
`backend/.env.local`

Example:
```env
TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
TELEGRAM_CHAT_ID=8608982148
ALERT_MIN_VERDICT=warn
```

> `backend/.env.local` is gitignored and must never be committed.

## 2) Reload services
```bash
cd /home/james/openclaw-workspace/appsec-redteam-copilot
docker compose down
docker compose up --build -d
```

## 3) Test alert path
```bash
curl -s -X POST "http://127.0.0.1:3480/alerts/test" | jq
```

Expected success:
```json
{"ok": true, "result": {"sent": true, "status": 200}}
```

## 4) Trigger pre-change analysis alerts
```bash
curl -s -X POST "http://127.0.0.1:3480/analyze-diff-hunks?path=/workspace/backend/api/main.py" | jq
```

Alert behavior:
- `allow` -> no alert
- `warn` -> alert if `ALERT_MIN_VERDICT=warn`
- `block` -> always alert for `warn/block` threshold

## Troubleshooting

### `{"detail":"Not Found"}` on `/alerts/test`
- endpoint not in running build -> rebuild containers.

### HTTP 500 on `/alerts/test`
- check logs:
```bash
docker compose logs --tail=120 appsec-copilot
```

### `missing_env`
- verify env loaded in container:
```bash
docker exec -it appsec-copilot sh -lc 'env | grep -E "TELEGRAM_BOT_TOKEN|TELEGRAM_CHAT_ID|ALERT_MIN_VERDICT"'
```

### No pre-change findings in Docker mode
- use container-visible path in API call:
`/workspace/...`

## Blocking behavior today
- **Telegram alerting** is active for `warn`/`block` verdicts.
- **Local code execution is NOT auto-blocked** in shell/PuTTY.
- **Commit blocking** occurs only when using the pre-commit hook workflow.
- **PR/CI blocking** occurs via GitHub Actions CI gate when thresholds fail.

## Local command verification wrapper (`safe-run`)
To require verification before executing risky commands locally:

```bash
bash scripts/safe-run.sh "your command here"
```

Behavior:
- `block` -> command is not executed
- `warn` -> asks user to type `YES` before executing
- `allow` -> executes immediately
