<p align="center">
  <img src="docs/00145.png" alt="Llama-Flex-Server Banner" style="width: 100%; max-width: 1200px; height: auto; border-radius: 8px; margin-bottom: 20px;">
</p>
<h1 align="center">🏆 Llama-Flex-Server</h1>

<p align="center">
  <img src="https://img.shields.io/badge/python-3.10+-blue?style=flat-square" alt="Python">
  <img src="https://img.shields.io/badge/CUDA-11.7+-green?style=flat-square" alt="CUDA">
  <img src="https://img.shields.io/badge/Windows-supported-brightgreen?style=flat-square" alt="Windows">
  <img src="https://img.shields.io/badge/macOS-supported-brightgreen?style=flat-square" alt="macOS">
  <img src="https://img.shields.io/badge/license-MIT-orange?style=flat-square" alt="License">
  <a href="https://github.com/handycn/flex-server"></a>
</p>

<p align="center" style="margin: 20px 0; font-size: 32px; font-weight: bold;">
  <span style="color: #ffcc00 !important;">&#9654;&#9654;&#9654;</span>
  <a href="README-EN.md" style="display: inline-block; padding: 12px 24px; background-color: #007bff; color: white !important; text-decoration: none; font-size: 18px; font-weight: bold; border-radius: 6px; margin: 0 15px;">
    english version
  </a>
  <span style="color: #ffcc00 !important;">&#9664;&#9664;&#9664;</span>
</p>

<p align="center">
  <strong>一个基于 llama-cpp-python 的 OpenAI 兼容 API 服务器</strong><br>
  🚀 支持多模态 (Qwen3-VL) + 纯文本模型 | 集成 Open WebUI 前端<br>
  ✨ 核心亮点：30秒自动释放显存 + 实时性能监控，彻底告别内存泄漏！
</p>
<p align="center">
  <img src="docs/2026-03-01 011030.png" alt="Demo Screenshot" width="800">
  <br>
  <em>（win终端性能监控）</em>
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
- [📋 配置文件](#-配置文件)
- [🧠 高级功能](#-高级功能)
- [📊 性能监控与显存管理](#-性能监控与显存管理)
- [🔧 项目文件说明](#-项目文件说明)
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

本项目的后端基于 [JamePeng/llama-cpp-python](https://github.com/JamePeng/llama-cpp-python) 分支开发，请前往该仓库查看详细的安装说明：

👉 [JamePeng/llama-cpp-python 安装指南](https://github.com/JamePeng/llama-cpp-python#installation)

根据你的硬件选择对应的安装方式：
```
- **Windows with NVIDIA GPU**：下载 Releases 页面中的 CUDA 版本 whl
- **macOS with Apple Silicon**：下载 Releases 页面中的 Metal 版本 whl
- **CPU only / 其他情况**：参考仓库说明从源码编译
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

## 📋 配置文件

macOS 用户：复制 config.macos.example.json 为 config.json

Windows 用户：复制 config.windows.example.json 为 config.json

复制配置文件模板并编辑 `path`：
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
auto_memory_filter.py 需要在 Open WebUI 的 Workspace → Functions 中导入

配合 memory.md 使用，可实现跨会话的长期记忆

* **使用方法：** 在 Open WebUI 「工作空间」→「函数」中导入该文件，并将 `self.memory_file` 指向你的 `memory.md` 路径。
<p align="center">
  <img src="docs/截屏2026-02-28 18.00.54.png" alt="Demo Screenshot" width="600">
  <br>
  <em>（函数添加位置）</em>
</p>
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

#### ⚠️ Windows 用户重要提示
由于 Windows 安全机制限制，使用 `localhost` 访问时可能导致 Google Drive 认证弹窗无法正常关闭（报错 `Popup window closed`）。

**解决方案：**
- 启动脚本已内置修复，强制使用 `127.0.0.1` 访问（`HOST=127.0.0.1`, `WEBUI_URL=http://127.0.0.1:8080`）
- 浏览器会自动打开 `http://127.0.0.1:8080` 而非 `localhost`
- 如果之前通过 `localhost` 访问过并保存了密码，请改用 `127.0.0.1` 重新登录

<p align="center">
  <img src="docs/截屏2026-02-28 17.55.16.png" alt="Google Drive 按钮" width="400">
  <img src="docs/截屏2026-02-28 17.54.42.png" alt="文档选择界面" width="400">
  <br>
  <em>Google Drive 按钮及文档选择界面</em>
</p>

---

### 🧬 多模型并发调用
服务器支持通过 `model_lock` 实现请求排队，避免多个模型请求导致显存冲突。

---

## 📊 性能监控与显存管理

系统内置实时性能统计和可配置的显存自动卸载机制，帮助您优化资源利用。

### 实时性能统计
每次推理完成后，终端自动打印详细的性能数据，方便您评估模型响应速度：

```bash
[后端] 推理完成 | 耗时: 11.11s | 生成tokens: 114 | 速度: 10.26 tokens/s
```

输出说明：
- **耗时**：从请求到完成的总时间（秒）
- **生成tokens**：模型本次生成的 token 数量
- **速度**：平均生成速度（tokens/秒）

### 可配置的显存自动卸载
系统内置显存自动释放机制，避免长时间占用 GPU 资源。您可以在 `flex_server.py` 中自定义卸载等待时间：

```python
# 在 flex_server.py 中找到并修改这个值（约第20行）
UNLOAD_DELAY = 30  # 单位：秒，可根据需求调整
```

### 实时倒计时与智能重置
设置生效后，每次推理完成会自动开始倒计时，并在**同一行动态刷新**显示剩余时间：

```bash
[后端] [系统] 显存将在 30 秒后释放...
```

倒计时数字会逐秒递减（30 → 29 → 28 ...），直到释放显存或收到新请求。

**智能重置机制**：如果在倒计时期间检测到新的推理请求，系统会自动取消释放任务，避免频繁加载/卸载影响体验：

```bash
[后端] [系统] 检测到新请求，倒计时重置。
```

此时倒计时会重新从 `UNLOAD_DELAY` 开始计数。

### 手动显存管理
除自动卸载外，您也可以通过以下方式手动管理显存：

- **重启服务**：终止 Python 进程可立即释放所有显存
- **切换模型**：加载新模型时会自动卸载当前模型
- **等待倒计时**：让系统自动完成卸载（终端显示 `[系统] 已超过 30s 未使用，自动卸载模型释放内存...`）
---

## 🔧 项目文件说明

| 文件名 | 说明 |
|--------|------|
| `flex_server.py` | 核心后端服务，基于 `llama-cpp-python` 的 OpenAI 兼容 API 服务器，支持流式输出、自动显存卸载、多模型切换 |
| `config.macos.example.json` | macOS 配置示例，复制为 `config.json` 并修改模型路径后使用 |
| `config.windows.example.json` | Windows 配置示例，复制为 `config.json` 并修改模型路径后使用 |
| `start_flex.macos.command` | macOS 一键启动脚本（双击运行），同时启动后端 + Open WebUI，支持实时日志显示 |
| `start_windows.bat` | Windows 一键启动脚本，自动检测 Windows Terminal 并分屏启动前后端 |
| `auto_memory_filter.py` | Open WebUI 函数插件，自动从本地 `memory.md` 读取长期记忆并注入系统提示词 |
| `memory.md` | 长期记忆文件示例（需复制为 `memory.md` 并修改内容） |
| `LICENSE` | MIT 开源许可证 |
| `docs/` | 文档目录（包含截图等资源） |

### 📌 补充说明（可选，放 README 末尾）
配置文件
config.macos.example.json 和 config.windows.example.json 是平台独立的，主要区别在于路径格式示例
使用时请复制为 config.json 并根据你的实际模型路径修改

启动脚本
macOS：start_flex.macos.command 双击即可运行，日志实时显示在终端
Windows：start_windows.bat 双击运行，自动检测 Windows Terminal，支持分屏显示

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

<img src="docs/00143.png" alt="分割线" style="width: 100%; max-width: 1200px; height: auto; border: none; margin: 15px 0;">

## 🙏 致谢
- [llama-cpp-python](https://github.com/abetlen/llama-cpp-python) (感谢 JamePeng 的llama_cpp_python-0.3.27版本彻底解决了显存泄露问题！)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Qwen](https://github.com/QwenLM/Qwen)

---
  MIT License © 2025 handycn<br>
  如果您觉得有用，欢迎给个 <b>Star ⭐</b>！
</p>


