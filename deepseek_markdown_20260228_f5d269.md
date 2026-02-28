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
  <strong>An OpenAI-compatible API server based on llama-cpp-python</strong><br>
  🚀 Supports Multimodal (Qwen3-VL) + Text-only Models | Integrated with Open WebUI Frontend<br>
  ✨ Key Highlight: 30-Second Auto VRAM Release + Real-time Performance Monitoring, Say Goodbye to Memory Leaks!
</p>
<p align="center">
  <img src="docs/2026-03-01 011030.png" alt="Demo Screenshot" width="800">
  <br>
  <em>(Windows terminal performance monitoring)</em>
<p align="center">
  <img src="docs/截屏2026-02-28 17.16.49.png" alt="Demo Screenshot" width="800">
  <br>
  <em>(macOS terminal performance monitoring)</em>
</p>

---

## 📖 Table of Contents
- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start)
- [📦 Full Installation & Configuration](#-full-installation--configuration)
- [📋 Configuration File](#-configuration-file)
- [🧠 Advanced Features](#-advanced-features)
- [📊 Performance Monitoring & VRAM Management](#-performance-monitoring--vram-management)
- [🔧 Project Files Description](#-project-files-description)
- [🐞 Troubleshooting](#-troubleshooting)

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 🧠 **Multi-Model Support** | Text-only + Multimodal (Qwen3-VL), hot-swappable via config file, supports any GGUF model |
| 🚀 **GPU Acceleration** | Supports CUDA/Metal, automatically unloads VRAM with a **30-second** countdown after each inference for efficient resource utilization |
| 📊 **Real-time Performance Stats** | Automatically prints after inference: Time Elapsed / Generated Tokens / Generation Speed (tokens/s) |
| ⚡ **High Concurrency Handling** | Model listing requests never block; multiple requests are queued without conflict |
| 💻 **Cross-Platform** | Verified on Windows (RTX 5070 Ti) and macOS (M3) |
| 🔌 **OpenAI Compatible** | Can be directly integrated with frontends like Open WebUI, ChatGPT-Next-Web, LobeChat, etc. |
| 💾 **Automatic Memory Injection** | Reads long-term memory from `memory.md` and automatically injects it into the conversation context |
| 🖥️ **One-Click Launch** | Scripts automatically start the backend + Open WebUI, display in split screen, ready to use out-of-the-box |

---

## 🚀 Quick Start

### Prerequisites
* Python 3.10+
* Git
* (Optional) CUDA 11.7+ / Metal (Mac)

### macOS / Linux
```bash
git clone https://github.com/handycn/Llama-Flex-Server.git
cd Llama-Flex-Server
chmod +x start_flex.macos.command
./start_flex.macos.command
```

### Windows (PowerShell)
```powershell
git clone https://github.com/handycn/Llama-Flex-Server.git
cd Llama-Flex-Server
start_windows.bat
```

🎉 After launching, visit **http://localhost:8080** to start chatting!

---

## 📦 Full Installation & Configuration

### 1. Create a Virtual Environment (Recommended)
```bash
# macOS/Linux
python -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
.\venv\Scripts\activate
```

### 2. Clone this Repository
```bash
git clone https://github.com/handycn/Llama-Flex-Server.git
cd Llama-Flex-Server
```

### 3. Install llama-cpp-python (Core Engine)

The backend of this project is developed based on the [JamePeng/llama-cpp-python](https://github.com/JamePeng/llama-cpp-python) fork. Please refer to that repository for detailed installation instructions:

👉 [JamePeng/llama-cpp-python Installation Guide](https://github.com/JamePeng/llama-cpp-python#installation)

Choose the installation method based on your hardware:
```
- **Windows with NVIDIA GPU**: Download the CUDA version wheel from the Releases page
- **macOS with Apple Silicon**: Download the Metal version wheel from the Releases page
- **CPU only / Other cases**: Refer to the repository instructions for building from source
```

### 4. Install API Service Dependencies
```bash
pip install fastapi uvicorn
```

### 5. Install Open WebUI (Frontend, Optional)

For detailed frontend instructions, please see: https://github.com/open-webui/open-webui

If Open WebUI is not yet installed:
```bash
pip install open-webui
```
---

## 📋 Configuration File

For macOS users: Copy `config.macos.example.json` to `config.json`

For Windows users: Copy `config.windows.example.json` to `config.json`

Copy the configuration file template and edit the `path`:
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

## 🧠 Advanced Features

### 💾 Automatic Memory Injection
`auto_memory_filter.py` needs to be imported into Open WebUI's Workspace → Functions

Used in conjunction with `memory.md` to enable long-term memory across sessions

* **Usage:** Import this file in Open WebUI's "Workspace" → "Functions", and point `self.memory_file` to your `memory.md` path.
<p align="center">
  <img src="docs/截屏2026-02-28 18.00.54.png" alt="Demo Screenshot" width="600">
  <br>
  <em>(Function addition location)</em>
</p>
<p align="center">
  <img src="docs/截屏2026-02-28 17.59.49.png" alt="Demo Screenshot" width="600">
  <br>
  <em>(Memory button in model settings)</em>
</p>

---

### ☁️ Google Drive Integration

To use Open WebUI's Google Drive attachment feature, configure in the startup script:

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

### 🧬 Multi-Model Concurrent Invocation
The server supports request queuing via `model_lock` to prevent VRAM conflicts caused by multiple model requests.

---

## 📊 Performance Monitoring & VRAM Management

The system features built-in real-time performance statistics and a configurable automatic VRAM unloading mechanism to help you optimize resource utilization.

### Real-time Performance Statistics
After each inference, the terminal automatically prints detailed performance data, allowing you to evaluate model response speed:

```bash
[Backend] Inference completed | Time: 11.11s | Generated tokens: 114 | Speed: 10.26 tokens/s
```

Output Description:
- **Time**: Total time from request to completion (seconds)
- **Generated tokens**: Number of tokens generated by the model in this session
- **Speed**: Average generation speed (tokens/second)

### Configurable Automatic VRAM Unloading
The system has a built-in automatic VRAM release mechanism to avoid long-term GPU resource occupation. You can customize the unload wait time in `flex_server.py`:

```python
# Find and modify this value in flex_server.py (around line 20)
UNLOAD_DELAY = 30  # Unit: seconds, adjust as needed
```

### Real-time Countdown & Intelligent Reset
Once the setting takes effect, the countdown starts automatically after each inference and **dynamically updates on the same line** showing the remaining time:

```bash
[Backend] [System] VRAM will be released in 30 seconds...
```

The countdown number decreases second by second (30 → 29 → 28 ...) until VRAM is released or a new request is received.

**Intelligent Reset Mechanism:** If a new inference request is detected during the countdown, the system automatically cancels the release task to avoid frequent loading/unloading affecting the user experience:

```bash
[Backend] [System] New request detected, countdown reset.
```

At this point, the countdown restarts from `UNLOAD_DELAY`.

### Manual VRAM Management
In addition to automatic unloading, you can also manage VRAM manually in the following ways:

- **Restart the service**: Terminating the Python process releases all VRAM immediately
- **Switch models**: Loading a new model automatically unloads the current one
- **Wait for the countdown**: Let the system complete unloading automatically (terminal displays `[System] No usage for over 30s, automatically unloading model to release memory...`)
---

## 🔧 Project Files Description

| File Name | Description |
|--------|------|
| `flex_server.py` | Core backend service, an OpenAI-compatible API server based on `llama-cpp-python`, supporting streaming output, automatic VRAM unloading, and multi-model switching |
| `config.macos.example.json` | macOS configuration example; copy to `config.json` and modify model paths before use |
| `config.windows.example.json` | Windows configuration example; copy to `config.json` and modify model paths before use |
| `start_flex.macos.command` | macOS one-click launch script (double-click to run), starts both backend + Open WebUI with real-time log display |
| `start_windows.bat` | Windows one-click launch script; automatically detects Windows Terminal and starts frontend/backend in split-screen view |
| `auto_memory_filter.py` | Open WebUI function plugin; automatically reads long-term memory from local `memory.md` and injects it into the system prompt |
| `memory.md` | Example long-term memory file (needs to be copied to `memory.md` and content modified) |
| `LICENSE` | MIT Open Source License |
| `docs/` | Documentation directory (contains screenshots, etc.) |

### 📌 Supplementary Notes (Optional, place at the end of README)
**Configuration File**
`config.macos.example.json` and `config.windows.example.json` are platform-independent; the main difference lies in the path format examples.
Copy the appropriate one to `config.json` and modify it according to your actual model paths.

**Startup Scripts**
- **macOS**: Double-click `start_flex.macos.command` to run; logs are displayed in real-time in the terminal.
- **Windows**: Double-click `start_windows.bat` to run; it automatically detects Windows Terminal and supports split-screen display.

---

## 🐞 Troubleshooting

<details>
<summary><b>1. Port 10000 is occupied?</b></summary>
<b>Windows:</b> <code>netstat -ano | findstr :10000</code> -> <code>taskkill /PID &lt;PID&gt; /F</code><br>
<b>macOS:</b> <code>lsof -i :10000</code> -> <code>kill -9 &lt;PID&gt;</code>
</details>

<details>
<summary><b>2. VRAM is not being released as expected?</b></summary>
Please ensure the inference wasn't forcibly interrupted. Check if the countdown logic in `flex_server.py` is triggered.
</details>

<details>
<summary><b>3. Garbled paths on Windows?</b></summary>
Execute <code>chcp 65001</code> in PowerShell before starting to switch the encoding to UTF-8.
</details>

---

## 🙏 Acknowledgements
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python) (Special thanks to JamePeng for the llama_cpp_python-0.3.27 version which completely solved the VRAM leak issue!)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Qwen](https://github.com/QwenLM/Qwen)

---
  MIT License © 2025 handycn<br>
  If you find this useful, please consider giving it a <b>Star ⭐</b>!
</p>