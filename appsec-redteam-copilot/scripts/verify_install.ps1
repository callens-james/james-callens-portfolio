$ErrorActionPreference = "Stop"
try { $h=Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3480/health -TimeoutSec 3; if($h.StatusCode -ne 200){throw "health"}; Write-Host "OK: health" } catch { Write-Host "FAIL: health"; exit 1 }
try { $d=Invoke-WebRequest -UseBasicParsing http://127.0.0.1:3480/dashboard -TimeoutSec 3; if($d.StatusCode -ne 200){throw "dash"}; Write-Host "OK: dashboard" } catch { Write-Host "FAIL: dashboard"; exit 1 }
Write-Host "OK: install verified"
