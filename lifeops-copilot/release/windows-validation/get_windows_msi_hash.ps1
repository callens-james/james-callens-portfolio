$msi = "LifeOps Copilot_0.3.0_x64_en-US.msi"
if (-not (Test-Path $msi)) {
  Write-Host "MSI not found in current directory: $msi" -ForegroundColor Yellow
  exit 1
}
Get-FileHash $msi -Algorithm SHA256 | Format-List
