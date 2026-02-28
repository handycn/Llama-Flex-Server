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
  <strong>一个基于 llama-cpp-python 的 OpenAI 兼容 API 服务器</strong><br>
  🚀 支持多模态 (Qwen3-VL) + 纯文本模型 | 集成 Open WebUI 前端<br>
  ✨ 核心亮点：30秒自动释放显存 + 实时性能监控，彻底告别内存泄漏！
</p>

<p align="center">
  <img src="docs/截屏2026-02-28 17.16.49.png" alt="Demo Screenshot" width="800">
  <br>
  <em>（mac终端性能监控）</em>
</p>

---

## 📖 目录
- [✨ 特性一览](#-特性一览)
- [🚀 快速开始](#-快速开始)
- [📦 完整安装与配置](#-完整安装与配置)
- [⚙️ 配置文件说明](#-配置文件)
- [🧠 高级功能](#-高级功能)
- [📊 性能监控与显存管理](#-性能监控与显存管理)
- [🖥️ 一键启动脚本说明](#-一键启动脚本)
- [🐞 常见问题排查](#-常见问题排查)

---

## ✨ 特性一览

| 特性 | 说明 |
| :--- | :--- |
| 🧠 **多模型支持** | 纯文本 + 多模态（Qwen3-VL），配置文件热切换，支持任意 GGUF 模型 |
| 🚀 **GPU 加速** | 支持 CUDA/Metal，每次推理后 **30 秒**倒计时自动卸载显存，高效利用资源 |
| 📊 **实时性能统计** | 推理后自动打印：耗时 / 生成 tokens / 生成速度 (tokens/s) |
| ⚡ **高并发处理** | 模型列表请求永不阻塞，多请求排队无冲突 |
| 💻 **跨平台** | 已在 Windows (RTX 5070 Ti) 和 macOS (M3) 上验证通过 |
| 🔌 **OpenAI 兼容** | 可直接对接 Open WebUI、ChatGPT-Next-Web、LobeChat 等前端 |
| 💾 **自动记忆注入** | 从 `memory.md` 读取长期记忆，自动注入对话上下文 |
| 🖥️ **一键启动** | 脚本自动启动后端 + Open WebUI，分屏显示，开箱即用 |

---

## 🚀 快速开始

### 前置要求
* Python 3.10+
* Git
* (可选)CUDA 11.7+ / Metal (Mac)

### macOS / Linux
```bash
git clone [https://github.com/handycn/flex-server.git](https://github.com/handycn/flex-server.git)
cd flex-server
chmod +x scripts/start_flex.sh
./scripts/start_flex.sh
```

### Windows (PowerShell)
```powershell
git clone [https://github.com/handycn/flex-server.git](https://github.com/handycn/flex-server.git)
cd flex-server
.\scripts\start_win.ps1
```

🎉 启动后，访问 **http://localhost:8080** 即可开始对话！

---

## 📦 完整安装与配置

### 1. 创建虚拟环境（推荐）
```bash
# macOS/Linux
python -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
.\venv\Scripts\activate
```

### 2. 克隆本仓库
```bash
git clone https://github.com/handycn/Llama-Flex-Server.git
cd Llama-Flex-Server
```

### 3. 安装 llama-cpp-python（核心引擎）
具体的后端说明，请参阅此处：https://github.com/JamePeng/llama-cpp-python

根据您的硬件选择一种方式：

**选项A：CPU 版本（通用）**
```bash
pip install llama-cpp-python
```

**选项B：GPU 加速（NVIDIA CUDA）- 推荐**
```bash
pip install llama-cpp-python --extra-index-url https://github.com/JamePeng/llama-cpp-python/releases
```

**选项C：Mac Metal 加速（Apple Silicon）**
```bash
CMAKE_ARGS="-DGGML_METAL=on" pip install llama-cpp-python
```

### 4. 安装 API 服务依赖
```bash
pip install fastapi uvicorn
```

### 5. 安装 Open WebUI（前端，可选）
具体的前端说明，请参阅此处：https://github.com/open-webui/open-webui

如果还没有安装 Open WebUI：
```bash
pip install open-webui
```
---

## ⚙️ 配置文件

复制配置文件模板 `config.json.example` 并编辑：`path`

复制模板并编辑路径：
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

## 🧠 高级功能

### 💾 自动记忆注入
<p align="center">
  <img src="docs/截屏2026-02-28 18.00.54.png" alt="Demo Screenshot" width="600">
  <br>
  <em>（函数添加位置）</em>
</p>

项目包含 `auto_memory_filter.py`，可自动从 `memory.md` 读取长期记忆并注入系统提示词。

* **使用方法：** 在 Open WebUI 「工作空间」→「函数」中导入该文件，并将 `self.memory_file` 指向你的 `memory.md` 路径。
<p align="center">
  <img src="docs/截屏2026-02-28 17.59.49.png" alt="Demo Screenshot" width="600">
  <br>
  <em>（模型设置memory按钮）</em>
</p>

---

### ☁️ Google Drive 集成

若需要使用 Open WebUI 的 Google Drive 附件功能，在启动脚本中配置：

```bash
export ENABLE_GOOGLE_DRIVE_INTEGRATION="true"
export GOOGLE_DRIVE_CLIENT_ID="你的client_id"
export GOOGLE_DRIVE_API_KEY="你的api_key"
```
<p align="center">
  <img src="docs/截屏2026-02-28 17.55.16.png" alt="Demo 1" width="400">
  <img src="docs/截屏2026-02-28 17.54.42.png" alt="Demo 2" width="400">
  <br>
  <em>（截图：google dirve按钮、文档选择）</em>
</p>

---

### 🧬 多模型并发调用
服务器支持通过 `model_lock` 实现请求排队，避免多个模型请求导致显存冲突。

---

### 📊 性能监控与显存管理

启动服务后，终端会实时显示推理状态与显存释放倒计时：

> `[后端] 推理完成 | 耗时: 11.11s | 生成tokens: 114 | 速度: 10.26 tokens/s`
>
> `[后端] [系统] 显存将在 30 秒后释放...`

---

## 🖥️ 一键启动脚本

| 脚本 | 平台 | 说明 |
| :--- | :--- | :--- |
| `start_flex.sh` | macOS/Linux | 日志输出到当前终端 |
| `start_win.ps1` | Windows | 推荐脚本，PowerShell 分屏显示日志 |
| `start_win.bat` | Windows | 传统批处理，兼容旧系统 |

---

## 🐞 常见问题排查

<details>
<summary><b>1. 端口 10000 被占用？</b></summary>
<b>Windows:</b> <code>netstat -ano | findstr :10000</code> -> <code>taskkill /PID &lt;PID&gt; /F</code><br>
<b>macOS:</b> <code>lsof -i :10000</code> -> <code>kill -9 &lt;PID&gt;</code>
</details>

<details>
<summary><b>2. 显存没有按预期释放？</b></summary>
请确保推理没有被强制中断，检查 <code>flex_server.py</code> 中的倒计时逻辑是否触发。
</details>

<details>
<summary><b>3. Windows 下路径乱码？</b></summary>
在启动 PowerShell 前先执行 <code>chcp 65001</code> 将编码切换为 UTF-8。
</details>

---

## 🙏 致谢
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python) (感谢 JamePeng 的llama_cpp_python-0.3.27版本彻底解决了显存泄露问题！)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Qwen](https://github.com/QwenLM/Qwen)

---
  MIT License © 2025 handycn<br>
  如果您觉得有用，欢迎给个 <b>Star ⭐</b>！
</p>


