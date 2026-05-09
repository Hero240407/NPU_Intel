# Qwen2.5-Coder NPU Server

Run Qwen2.5-Coder models locally on an Intel NPU via OpenVINO GenAI, exposed as an OpenAI-compatible completions API.

## Requirements

- Intel NPU (e.g. Core Ultra series)
- Python 3.10+
- Windows

## Setup

### 1. Create and activate a virtual environment

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Compile the model

**0.5B model:**
```bash
optimum-cli export openvino -m Qwen/Qwen2.5-Coder-0.5B --weight-format int4 --sym --ratio 1.0 --group-size 128 qwen2.5-coder-0.5b-npu-ov
```

**1.5B model:**
```bash
optimum-cli export openvino --model Qwen/Qwen2.5-Coder-1.5B --weight-format int4 qwen2.5-coder-1.5b-ov
```

## Running

Edit `npu_start.ps1` and set `$MODEL_SIZE` to `"0.5b"` or `"1.5b"`, then run:

```powershell
.\npu_start.ps1
```

Or double-click `npu_start.ps1` (requires PowerShell execution policy set to `RemoteSigned`):

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

The server starts at `http://127.0.0.1:8000` and exposes `POST /v1/completions`.
