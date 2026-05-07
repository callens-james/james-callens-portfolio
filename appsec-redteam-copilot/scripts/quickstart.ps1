$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "Docker is not installed. Install Docker Desktop first." -ForegroundColor Red
  exit 1
}

docker compose up --build -d | Out-Host

$ok = $false
for ($i=0; $i -lt 30; $i++) {
  try {
    $resp = Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3480/health -TimeoutSec 2
    if ($resp.StatusCode -eq 200) { $ok = $true; break }
  } catch {}
  Start-Sleep -Seconds 1
}

if ($ok) {
  Write-Host "AppSec Copilot is live: http://127.0.0.1:3480/dashboard" -ForegroundColor Green
  Write-Host "Next: open dashboard, run First-Run Setup, set your project path."
} else {
  Write-Host "Health check failed. Run: docker compose logs --tail=120 appsec-copilot" -ForegroundColor Yellow
  exit 2
}
