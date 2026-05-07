$ErrorActionPreference = "Stop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Host "FAIL: docker not installed"; exit 1 }
try { docker compose version | Out-Null } catch { Write-Host "FAIL: docker compose unavailable"; exit 1 }
try { docker ps | Out-Null } catch { Write-Host "FAIL: no docker daemon access"; exit 1 }
if (Test-Path "backend/.env.local") { Write-Host "OK: backend/.env.local found" } else { Write-Host "WARN: backend/.env.local missing (alerts disabled)" }
Write-Host "[preflight] done"
