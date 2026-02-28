#!/bin/bash
echo "------------------------------------------------"
echo "🚀 启动自定义 Flex 后端 + Open WebUI"
echo "------------------------------------------------"

# [cite_start]启动后端：直接运行，不再通过 sed 过滤，以支持 \r 原地刷新 [cite: 3, 4]
cd /Users/zhuyanan/Documents/llama-cpp-python
source venv/bin/activate
export PATH="/Users/zhuyanan/Documents/llama-cpp-python/venv/bin:$PATH"
export PYTHONUNBUFFERED=1

# 这里去掉了 sed，确保倒计时能够实时显示
python flex_server.py 2>/dev/null &
BACKEND_PID=$!
echo -e "\033[34m[后端]\033[0m 已启动 (PID: $BACKEND_PID, 端口: 10000)"

sleep 3

# [cite_start]启动 Open WebUI：保持静默 [cite: 5]
cd /Users/zhuyanan/Documents/open-webui
source .venv/bin/activate

# OpenAI API 配置
export OPENAI_API_BASE_URL="http://127.0.0.1:10000/v1"
export OLLAMA_BASE_URL=""

# Google Drive 集成配置（请替换为你的实际凭据）
export ENABLE_GOOGLE_DRIVE_INTEGRATION="true"
export GOOGLE_DRIVE_CLIENT_ID="603733063667-lg5ch5i94jm2okj6341es8kmqr32omfl.apps.googleusercontent.com"
export GOOGLE_DRIVE_API_KEY="AIzaSyAoPGUPbAHA9BUSokvcj-pXanm3JZCdGdk"

echo -e "\033[32m[前端]\033[0m 正在启动..."
open-webui serve >/dev/null 2>&1 &
FRONTEND_PID=$!
echo -e "\033[32m[前端]\033[0m 已启动 (PID: $FRONTEND_PID, 端口: 8080)"

echo "------------------------------------------------"
echo "✨ 所有服务已启动，请访问 http://localhost:8080"
echo "按 Ctrl+C 终止所有进程"
echo "------------------------------------------------"

wait $BACKEND_PID $FRONTEND_PID