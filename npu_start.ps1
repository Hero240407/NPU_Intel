# ============================================================
# NPU Model Launcher
# Change MODEL_SIZE to "1.5b" or "0.5b" to select the model
# ============================================================
$MODEL_SIZE = "npu_0.5b"
# ============================================================

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
