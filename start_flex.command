#!/bin/bash

# --- 1. 路径配置 ---
BACKEND_DIR="/path/llama-cpp-python"
FRONTEND_DIR="/path/open-webui"

# --- 2. 环境变量 ---
export ENABLE_GOOGLE_DRIVE_INTEGRATION="true"
export GOOGLE_DRIVE_CLIENT_ID="****"
export GOOGLE_DRIVE_API_KEY="****E"
export OPENAI_API_BASE_URL="http://127.0.0.1:10000/v1"
export OLLAMA_BASE_URL=""
export PYTHONUNBUFFERED=1

# --- 3. 环境清理 (移除所有可能导致冲突的旧进程) ---
echo "------------------------------------------------"
echo "🚀 初始化 猛兽工作站"
echo "------------------------------------------------"
lsof -ti:10000,8080 | xargs kill -9 >/dev/null 2>&1
pkill -f "flex_server.py"
pkill -f "open-webui"
pkill -f "open-terminal"
sleep 2

# --- 4. 启动前端与终端 (后台静默) ---
cd "$FRONTEND_DIR"
source .venv/bin/activate
# 前端只显示错误
open-webui serve 2>&1 | grep -E "ERROR|WARNING|Critical" &
open-terminal run --port 8000 --api-key 123456 >/dev/null 2>&1 &

# --- 5. 启动后端 (这是唯一一次启动，放在前台显示日志) ---
echo -e "\033[34m[后端]\033[0m 推理引擎启动中，请稍后浏览器将自动开启..."
echo "------------------------------------------------"

# 开启一个后台检测任务：等 8080 好了就开浏览器，不影响当前窗口看后端日志
(
    until $(curl -s -f -o /dev/null http://localhost:8080); do
        sleep 2
    done
    open http://localhost:8080
) &

# 关键：在这里直接启动后端，让它占据整个终端窗口
cd "$BACKEND_DIR"
source venv/bin/activate
python flex_server.py
