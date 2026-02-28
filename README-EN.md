# 🏆 Llama-Flex-Server

<p align="center">
  <img src="https://img.shields.io/badge/python-3.10+-blue?style=flat-square" alt="Python">
  <img src="https://img.shields.io/badge/CUDA-11.7+-green?style=flat-square" alt="CUDA">
  <img src="https://img.shields.io/badge/Windows-supported-brightgreen?style=flat-square" alt="Windows">
  <img src="https://img.shields.io/badge/macOS-supported-brightgreen?style=flat-square" alt="macOS">
  <img src="https://img.shields.io/badge/license-MIT-orange?style=flat-square" alt="License">
  <a href="https://github.com/handycn/flex-server"></a>
</p>

<p align="center">
  <strong>An OpenAI-Compatible API Server based on llama-cpp-python</strong><br>
  🚀 Supports Multimodal (Qwen3-VL) + Text-only models | Integrated Open WebUI Frontend<br>
  ✨ Core Highlight: 30s Auto VRAM Release + Real-time Performance Monitoring, say goodbye to memory leaks!
</p>
<p align="center">
  <img src="docs/2026-03-01 011030.png" alt="Demo Screenshot" width="800">
  <br>
  <em>(Performance monitoring on Windows terminal)</em>
<p align="center">
  <img src="docs/截屏2026-02-28 17.16.49.png" alt="Demo Screenshot" width="800">
  <br>
  <em>(Performance monitoring on macOS terminal)</em>
</p>

---

## 📖 Table of Contents
- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start)
- [📦 Full Installation and Configuration](#-full-installation-and-configuration)
- [📋 Configuration File](#-configuration-file)
- [🧠 Advanced Functions](#-advanced-functions)
- [📊 Performance Monitoring & VRAM Management](#-performance-monitoring--vram-management)
- [🔧 Project File Descriptions](#-project-file-descriptions)
- [🐞 Troubleshooting](#-troubleshooting)

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 🧠 **Multi-Model Support** | Text + Multimodal (Qwen3-VL), hot-swapping via config, supports any GGUF model |
| 🚀 **GPU Acceleration** | Supports CUDA/Metal; **30-second** countdown to auto-unload VRAM after inference for efficient resource usage |
| 📊 **Real-time Stats** | Auto-prints after inference: Duration / Tokens Generated / Generation Speed (tokens/s) |
| ⚡ **High Concurrency** | Model list requests never block; multiple requests queue without conflict |
| 💻 **Cross-Platform** | Verified on Windows (RTX 5070 Ti) and macOS (M3) |
| 🔌 **OpenAI Compatible** | Connect directly to Open WebUI, ChatGPT-Next-Web, LobeChat, etc. |
| 💾 **Auto Memory Injection** | Reads from `memory.md` for long-term memory, automatically injected into context |
| 🖥️ **One-Click Start** | Scripts auto-start backend + Open WebUI in split screens; ready to use out of the box |

---

## 🚀 Quick Start

### Prerequisites
* Python 3.10+
* Git
* (Optional) CUDA 11.7+ / Metal (Mac)

### macOS / Linux
```bash
git clone [https://github.com/handycn/Llama-Flex-Server.git](https://github.com/handycn/Llama-Flex-Server.git)
cd Llama-Flex-Server
chmod +x start_flex.macos.command
./start_flex.macos.command
```

### Windows (PowerShell)
```powershell
git clone [https://github.com/handycn/Llama-Flex-Server.git](https://github.com/handycn/Llama-Flex-Server.git)
cd Llama-Flex-Server
./start_windows.bat
```

🎉 Once started, visit **http://localhost:8080** to start chatting!

---

## 📦 Full Installation and Configuration

### 1. Create Virtual Environment (Recommended)
```bash
# macOS/Linux
python -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
.\venv\Scripts\activate
```

### 2. Clone the Repository
```bash
git clone [https://github.com/handycn/Llama-Flex-Server.git](https://github.com/handycn/Llama-Flex-Server.git)
cd Llama-Flex-Server
```

### 3. Install llama-cpp-python (Core Engine)

The backend is developed based on the [JamePeng/llama-cpp-python](https://github.com/JamePeng/llama-cpp-python) branch. Please check that repository for detailed installation guides:

👉 [JamePeng/llama-cpp-python Installation Guide](https://github.com/JamePeng/llama-cpp-python#installation)

Choose the installation method based on your hardware:
```
- **Windows with NVIDIA GPU**: Download the CUDA version .whl from the Releases page.
- **macOS with Apple Silicon**: Download the Metal version .whl from the Releases page.
- **CPU only / Other cases**: Refer to the repo for compiling from source.
```

### 4. Install API Service Dependencies
```bash
pip install fastapi uvicorn
```

### 5. Install Open WebUI (Frontend, Optional)
For specific frontend instructions, refer to: https://github.com/open-webui/open-webui

If you haven't installed Open WebUI yet:
```bash
pip install open-webui
```
---

## 📋 Configuration File

macOS users: Copy `config.macos.example.json` to `config.json`

Windows users: Copy `config.windows.example.json` to `config.json`

Edit the `path` in your configuration:
```json
{
  "models": [
    {
      "name": "qwen3-vl-8b",
      "path": "/path/to/your/qwen3-vl-8b.Q8_0.gguf",
      "mmproj_path": "/path/to/your/qwen3-vl-mmproj-f16.gguf",
      "n_ctx": 4096,
      "n_gpu_layers": -1
    },
    {
      "name": "qwen3-8b",
      "path": "/path/to/your/qwen3-8b-Q6_K.gguf",
      "mmproj_path": null,
      "n_ctx": 4096,
      "n_gpu_layers": -1
    }
  ]
}
```

---

## 🧠 Advanced Functions

### 💾 Auto Memory Injection
`auto_memory_filter.py` needs to be imported into Open WebUI under Workspace → Functions.

Used with `memory.md`, it achieves long-term memory across sessions.

* **Usage:** Import this file in Open WebUI "Workspace" → "Functions", and point `self.memory_file` to your `memory.md` path.
<p align="center">
  <img src="docs/截屏2026-02-28 18.00.54.png" alt="Function location" width="600">
  <br>
  <em>(Function addition location)</em>
</p>
<p align="center">
  <img src="docs/截屏2026-02-28 17.59.49.png" alt="Memory button" width="600">
  <br>
  <em>(Model settings memory button)</em>
</p>

---

### ☁️ Google Drive Integration

If you need to use the Google Drive attachment feature in Open WebUI, configure it in the startup script:

```bash
export ENABLE_GOOGLE_DRIVE_INTEGRATION="true"
export GOOGLE_DRIVE_CLIENT_ID="your_client_id"
export GOOGLE_DRIVE_API_KEY="your_api_key"
```
<p align="center">
  <img src="docs/截屏2026-02-28 17.55.16.png" alt="Demo 1" width="400">
  <img src="docs/截屏2026-02-28 17.54.42.png" alt="Demo 2" width="400">
  <br>
  <em>(Screenshots: Google Drive button, document selection)</em>
</p>

---

### 🧬 Multi-Model Concurrency
The server supports request queuing via `model_lock` to prevent VRAM conflicts from multiple model requests.

---

## 📊 Performance Monitoring & VRAM Management

Built-in real-time stats and configurable auto-unload mechanism help optimize resource usage.

### Real-time Performance Stats
After each inference, the terminal automatically prints performance data:

```bash
[Backend] Inference Complete | Duration: 11.11s | Tokens: 114 | Speed: 10.26 tokens/s
```

Output details:
- **Duration**: Total time from request to completion (s)
- **Tokens**: Number of tokens generated
- **Speed**: Average generation speed (tokens/s)

### Configurable VRAM Auto-Unload
The system automatically releases VRAM to avoid idling GPU resources. You can customize the delay in `flex_server.py`:

```python
# Find and modify this value in flex_server.py (approx. line 20)
UNLOAD_DELAY = 30  # Units: seconds, adjust as needed
```

### Real-time Countdown & Intelligent Reset
After inference, a countdown starts and updates **dynamically on the same line**:

```bash
[Backend] [System] VRAM will be released in 30 seconds...
```

**Intelligent Reset**: If a new request is received during the countdown, the system automatically cancels the release task to avoid frequent reloading:

```bash
[Backend] [System] New request detected, countdown reset.
```

---

## 🔧 Project File Descriptions

| Filename | Description |
|--------|------|
| `flex_server.py` | Core backend service; OpenAI-compatible API server based on `llama-cpp-python`. Supports streaming, auto VRAM unloading, and model switching. |
| `config.macos.example.json` | macOS config example. Copy to `config.json` and modify paths. |
| `config.windows.example.json` | Windows config example. Copy to `config.json` and modify paths. |
| `start_flex.macos.command` | macOS one-click script. Starts backend + Open WebUI with real-time logs. |
| `start_windows.bat` | Windows one-click script. Detects Windows Terminal and starts split screens. |
| `auto_memory_filter.py` | Open WebUI function plugin; injects `memory.md` into system prompts. |
| `memory.md` | Long-term memory example file. |
| `LICENSE` | MIT License |
| `docs/` | Documentation assets (screenshots, etc.) |

---

## 🐞 Troubleshooting

<details>
<summary><b>1. Port 10000 is occupied?</b></summary>
<b>Windows:</b> <code>netstat -ano | findstr :10000</code> -> <code>taskkill /PID &lt;PID&gt; /F</code><br>
<b>macOS:</b> <code>lsof -i :10000</code> -> <code>kill -9 &lt;PID&gt;</code>
</details>

<details>
<summary><b>2. VRAM not releasing as expected?</b></summary>
Ensure inference wasn't forcefully interrupted; check if the countdown logic in <code>flex_server.py</code> was triggered.
</details>

<details>
<summary><b>3. Path encoding issues on Windows?</b></summary>
Run <code>chcp 65001</code> in PowerShell to switch to UTF-8 before starting.
</details>

---

## 🙏 Credits
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python) (Special thanks to JamePeng's 0.3.27 version for solving VRAM leaks!)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Qwen](https://github.com/QwenLM/Qwen)

---
  MIT License © 2025 handycn<br>
  If you find this useful, please give a **Star ⭐**!
</p>
