# Qwen2.5-Coder NPU Server

Run Qwen2.5-Coder models locally on an Intel NPU via OpenVINO GenAI, exposed as an OpenAI-compatible completions API.

## 📋 System Requirements

### Minimum Requirements
> Goal: Functional but may experience latency during heavy multi-tasking.

| Component | Minimum |
|-----------|---------|
| **Processor** | Intel® Core™ Ultra (Series 1 "Meteor Lake" or newer) with integrated NPU |
| **Memory (RAM)** | 16GB DDR5 — 8GB is technically enough for the model alone, but Windows 11 and VS Code will cause swapping and lag |
| **NPU Capacity** | 10 TOPS (NPU 2.0 or 3.0) |
| **Storage** | 5GB free space (for INT4 quantized weights and OpenVINO IR files) |
| **Software** | OpenVINO™ GenAI 2025.4+, Windows 11 (23H2 or newer) with the latest Intel NPU Driver |

### Recommended Requirements
> Goal: Sub-50ms latency for autocomplete and smooth `@codebase` indexing.

| Component | Recommended |
|-----------|------------|
| **Processor** | Intel® Core™ Ultra 5 245K or Ultra 7 265KF (Series 2 "Arrow Lake") |
| **Memory (RAM)** | 32GB Dual-Channel DDR5 (2×16GB) — dual-channel is ~20% faster for LLM inference; single-channel is a major bottleneck as the NPU shares system bandwidth |
| **NPU Capacity** | 40+ TOPS (NPU 4.0 "Lunar Lake" or "Arrow Lake" high-tier) |
| **Storage** | NVMe SSD (for fast model loading into NPU memory) |

## 📊 Model RAM Usage

Running with INT4 Symmetric Quantization (required for NPU stability):

| Model | Weight Size (Disk) | Active RAM Usage | Recommended Context Window |
|-------|-------------------|-----------------|---------------------------|
| Qwen 2.5 Coder 0.5B | ~350 MB | ~1.2 GB | Up to 8k tokens |
| Qwen 2.5 Coder 1.5B | ~1.1 GB | ~3.5 GB | Up to 4k tokens |

> **VS Code overhead:** VS Code + the Continue extension consume an additional ~2GB of RAM on top of the model.

## 💡 Developer Notes

- **Single-channel RAM:** If using single-channel RAM (common in some pre-builts or budget builds), use the **0.5B model only**. The 1.5B model will stutter because the NPU cannot fetch data from RAM fast enough.
- **Symmetric quantization required:** Always export models with `--sym --ratio 1.0`. Asymmetric models frequently trigger "Duplicated Name" errors in the VPUX compiler (NPU compiler) and will silently fall back to CPU.
- **Python 3.10+**

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

The server starts at `http://127.0.0.1:8005` and exposes `POST /v1/completions`.

## Continue IDE Integration

The NPU server is best used as an **autocomplete** model in [Continue](https://continue.dev). It runs very well for tab-completion and is responsive enough for real-time suggestions on Intel NPU hardware.

> **Note:** It can technically be configured as an `embed` role, but this is **not recommended** — dedicated embedding models (e.g. `nomic-embed-text`) are significantly faster and produce better results for retrieval tasks.

### config.yaml snippet

Add one of the following entries to your `~/.continue/config.yaml` under `models:`, depending on which model you are running:

**0.5B (recommended for autocomplete — faster, lower memory):**
```yaml
- name: "NPU Autocomplete"
  provider: "openai"
  model: "qwen2.5-coder:0.5b"
  apiBase: "http://127.0.0.1:8005/v1"
  roles:
    - autocomplete
```

**1.5B (slightly higher quality, uses more NPU memory):**
```yaml
- name: "NPU Autocomplete"
  provider: "openai"
  model: "qwen2.5-coder:1.5b"
  apiBase: "http://127.0.0.1:8005/v1"
  roles:
    - autocomplete
```

Make sure `npu_start.ps1` is running before starting your editor session.
