# ============================================================
# NPU Model Launcher
# Change MODEL_SIZE to "1.5b" or "0.5b" to select the model
# ============================================================
$MODEL_SIZE = "npu_0.5b"
# ============================================================

if ([string]::IsNullOrWhiteSpace($MODEL_SIZE)) {
    Write-Host ""
    Write-Host "ERROR: MODEL_SIZE is not set." -ForegroundColor Red
    Write-Host "  Open npu_start.ps1 and set the MODEL_SIZE variable to '0.5b' or '1.5b'." -ForegroundColor Yellow
    Write-Host "  Then save the file and run it again." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

if ($MODEL_SIZE -eq "1.5b") {
    $Target = "new_npu.py"
} elseif ($MODEL_SIZE -eq "0.5b") {
    $Target = "npu_0.5.py"
} else {
    Write-Host "ERROR: MODEL_SIZE must be '1.5b' or '0.5b'. Got: '$MODEL_SIZE'" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Starting NPU server with model $MODEL_SIZE ($Target)..." -ForegroundColor Cyan

# Activate .venv if present
if (Test-Path "$ScriptDir\.venv\Scripts\Activate.ps1") {
    & "$ScriptDir\.venv\Scripts\Activate.ps1"
}

python $Target

pause
