# 🏆 Llama-Flex-Server

<p align="center">
  <img src="https://img.shields.io/badge/python-3.10+-blue?style=flat-square" alt="Python">
  <img src="https://img.shields.io/badge/CUDA-11.7+-green?style=flat-square" alt="CUDA">
  <img src="https://img.shields.io/badge/Windows-supported-brightgreen?style=flat-square" alt="Windows">
  <img src="https://img.shields.io/badge/macOS-supported-brightgreen?style=flat-square" alt="macOS">
  <img src="https://img.shields.io/badge/license-MIT-orange?style=flat-square" alt="License">
  <a href="https://github.com/handycn/flex-server"><img src="https://img.shields.io/github/stars/handycn/flex-server?style=social" alt="Stars"></a>
</p>

<p align="center">
  <strong>一个基于 llama-cpp-python 的 OpenAI 兼容 API 服务器</strong><br>
  🚀 支持多模态 (Qwen3-VL) + 纯文本模型 | 集成 Open WebUI 前端<br>
  ✨ 核心亮点：30秒自动释放显存 + 实时性能监控，彻底告别内存泄漏！
</p>

<p align="center">
  <img src="docs/images/demo.png" alt="Demo Screenshot" width="800">
  <br>
  <em>（终端性能监控 + Open WebUI 对话界面）</em>
</p>

---

## 📖 目录
- [✨ 特性一览](#-特性一览)
- [🚀 快速开始](#-快速开始)
- [📦 完整安装与配置](#-完整安装与配置)
- [⚙️ 配置文件说明](#-配置文件说明)
- [🧠 高级功能](#-高级功能)
- [📊 性能监控与显存管理](#-性能监控与显存管理)
- [🖥️ 一键启动脚本说明](#-一键启动脚本说明)
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

## 🚀 快速开始（30秒启动）

### 前置要求
* Python 3.10+
* Git
* （可选）CUDA 11.7+ / Metal (Mac)

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

### 1. 克隆仓库与环境准备
```bash
git clone [https://github.com/handycn/flex-server.git](https://github.com/handycn/flex-server.git)
cd flex-server
python -m venv venv

# 激活环境
# macOS/Linux: source venv/bin/activate
# Windows: .\venv\Scripts\activate
```

### 2. 安装后端依赖
```bash
# 基础版本
pip install -r requirements.txt

# GPU 加速版本 (CUDA)
pip install llama-cpp-python --extra-index-url [https://github.com/JamePeng/llama-cpp-python/releases](https://github.com/JamePeng/llama-cpp-python/releases)

# Mac Metal 加速
CMAKE_ARGS="-DGGML_METAL=on" pip install llama-cpp-python
```

### 3. 安装前端与模型配置
```bash
pip install open-webui
```

**配置 `config.json`：**
复制模板并编辑路径：
```json
{
  "models": [
    {
      "name": "qwen3-vl-8b",
      "path": "/path/to/your/Qwen3-VL-8B-Instruct-Q8_0.gguf",
      "mmproj_path": "/path/to/your/mmproj-Qwen3-VL-8B-Instruct-F16.gguf",
      "n_ctx": 4096,
      "n_gpu_layers": -1
    }
  ]
}
```

---

## 🧠 高级功能

### 1. 自动记忆注入
项目包含 `auto_memory_filter.py`，可自动从 `memory.md` 读取长期记忆并注入系统提示词。

* **使用方法：** 在 Open WebUI 「工作空间」→「函数」中导入该文件，并将 `self.memory_file` 指向你的 `memory.md` 路径。

### 2. 多模型并发调用
服务器支持通过 `model_lock` 实现请求排队，避免多个模型请求导致显存冲突。

---

## 📊 性能监控与显存管理

启动服务后，终端会实时显示推理状态与显存释放倒计时：

> `[后端] 推理完成 | 耗时: 11.11s | 生成tokens: 114 | 速度: 10.26 tokens/s`
>
> `[后端] [系统] 显存将在 30 秒后释放...`

---

## 🖥️ 一键启动脚本说明

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
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python) (感谢 JamePeng 的预编译支持)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Qwen](https://github.com/QwenLM/Qwen)

---
<p align="center">
  MIT License © 2025 handycn<br>
  如果您觉得有用，欢迎给个 <b>Star ⭐</b>！
</p>

[![Star History Chart](https://api.star-history.com/svg?repos=handycn/flex-server&type=Date)](https://star-history.com/#handycn/flex-server&Date)
