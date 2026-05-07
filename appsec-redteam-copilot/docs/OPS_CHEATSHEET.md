# AppSec Copilot Ops Cheat Sheet

## Status
```bash
sudo systemctl status appsec-copilot.service --no-pager -l
docker compose -f <PROJECT_ROOT>/docker-compose.yml ps
curl -s http://127.0.0.1:3480/health
```

## Start
```bash
sudo systemctl start appsec-copilot.service
```

## Stop
```bash
sudo systemctl stop appsec-copilot.service
```

## Restart
```bash
sudo systemctl restart appsec-copilot.service
```

## Enable on boot
```bash
sudo systemctl enable appsec-copilot.service
```

## Disable on boot
```bash
sudo systemctl disable appsec-copilot.service
```

## Logs
```bash
sudo journalctl -u appsec-copilot.service -n 100 --no-pager
docker compose -f <PROJECT_ROOT>/docker-compose.yml logs -f appsec-copilot
docker compose -f <PROJECT_ROOT>/docker-compose.yml logs -f appsec-watcher
```

## Rebuild after code changes
```bash
cd <PROJECT_ROOT>
docker compose down
docker compose up --build -d
sudo systemctl restart appsec-copilot.service
```

## Dashboard URL
- Local: `http://127.0.0.1:3480/dashboard`
- LAN: `http://192.168.1.170:3480/dashboard`
