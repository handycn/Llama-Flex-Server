#!/bin/bash
echo "------------------------------------------------"
echo "🚀 启动自定义 Flex 后端 + Open WebUI"
echo "------------------------------------------------"

# 后端启动
cd /path/to/llama-cpp-python          # 请修改为你的后端路径
source venv/bin/activate
export PATH="/path/to/llama-cpp-python/venv/bin:$PATH"  # 请修改为你的后端路径
export PYTHONUNBUFFERED=1

python flex_server.py 2>/dev/null &
BACKEND_PID=$!
echo -e "\033[34m[后端]\033[0m 已启动 (PID: $BACKEND_PID, 端口: 10000)"

sleep 3

# 前端启动
cd /path/to/open-webui                # 请修改为你的前端路径
source .venv/bin/activate

export OPENAI_API_BASE_URL="http://127.0.0.1:10000/v1"
export OLLAMA_BASE_URL=""

# Google Drive 集成配置（如需使用请填写）
export ENABLE_GOOGLE_DRIVE_INTEGRATION="true"
export GOOGLE_DRIVE_CLIENT_ID="your_client_id_here"
export GOOGLE_DRIVE_API_KEY="your_api_key_here"

echo -e "\033[32m[前端]\033[0m 正在启动..."
open-webui serve >/dev/null 2>&1 &
FRONTEND_PID=$!
echo -e "\033[32m[前端]\033[0m 已启动 (PID: $FRONTEND_PID, 端口: 8080)"

echo "------------------------------------------------"
echo "✨ 所有服务已启动，请访问 http://localhost:8080"
echo "按 Ctrl+C 终止所有进程"
echo "------------------------------------------------"

wait $BACKEND_PID $FRONTEND_PID
