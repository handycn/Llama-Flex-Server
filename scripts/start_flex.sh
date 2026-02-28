#!/bin/bash

# 强制清场
pkill -f flex_server.py
pkill -f open-webui

echo "------------------------------------------------"
echo "🚀 启动自定义 Flex 后端 + Open WebUI"
echo "------------------------------------------------"

# ---------- 1. 启动后端 (flex_server.py) ----------
cd /Users/zhuyanan/Documents/llama-cpp-python
# 直接用绝对路径，避免激活问题
/Users/zhuyanan/Documents/llama-cpp-python/venv/bin/python flex_server.py > /tmp/flex_server.log 2>&1 &
BACKEND_PID=$!
echo "✅ 后端已启动 (PID: $BACKEND_PID, 端口: 10000, 日志: /tmp/flex_server.log)"

# 等待后端加载（可根据需要延长）
sleep 5

# ---------- 2. 启动前端 (open-webui) ----------
export OPENAI_API_BASE_URL="http://127.0.0.1:10000/v1"
cd /Users/zhuyanan/Documents/open-webui
source .venv/bin/activate
open-webui serve > /tmp/open_webui.log 2>&1 &
FRONTEND_PID=$!
echo "✅ 前端已启动 (PID: $FRONTEND_PID, 端口: 8080, 日志: /tmp/open_webui.log)"

echo "✨ 所有服务已启动，请访问 http://localhost:8080"
echo "按 Ctrl+C 终止所有进程"

# 等待用户中断
wait $BACKEND_PID $FRONTEND_PID