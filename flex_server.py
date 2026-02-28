import json
import gc
import asyncio
import time
from typing import List, Optional, Dict, Any
import functools

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

from llama_cpp import Llama
from llama_cpp.llama_chat_format import Qwen3VLChatHandler

# ---------- 加载配置 ----------
CONFIG_FILE = "config.json"
with open(CONFIG_FILE, "r") as f:
    config = json.load(f)

# ---------- 全局变量 ----------
current_model: Optional[Llama] = None
current_model_name: Optional[str] = None
model_lock = asyncio.Lock()
models_config = {m["name"]: m for m in config["models"]}

# --- 自动卸载逻辑配置 ---
unload_task: Optional[asyncio.Task] = None
UNLOAD_DELAY = 30  # 30秒倒计时

def unload_model():
    global current_model, current_model_name
    if current_model is not None:
        try:
            print(f"\r\033[K\033[33m[系统] 已超过 {UNLOAD_DELAY}s 未使用，自动卸载模型释放内存...\033[0m")
            current_model.close()
        except Exception:
            pass
        current_model = None
        current_model_name = None
    gc.collect()

async def schedule_unload_with_countdown():
    """带倒计时的后台任务"""
    global unload_task
    try:
        for i in range(UNLOAD_DELAY, 0, -1):
            print(f"\r[后端] \033[36m[系统] 显存将在 {i} 秒后释放... \033[0m", end="", flush=True)
            await asyncio.sleep(1)
        async with model_lock:
            unload_model()
    except asyncio.CancelledError:
        print(f"\r\033[K\033[32m[后端] [系统] 检测到新请求，倒计时重置。\033[0m", flush=True)

def load_model(model_name: str) -> Llama:
    global current_model, current_model_name, unload_task
    
    if unload_task:
        unload_task.cancel()
        unload_task = None

    if current_model is not None and current_model_name == model_name:
        return current_model
    
    unload_model()
    cfg = models_config.get(model_name)
    
    chat_handler = None
    if cfg.get("mmproj_path"):
        chat_handler = Qwen3VLChatHandler(
            clip_model_path=cfg["mmproj_path"],
            force_reasoning=False,
            image_min_tokens=1024,
            image_max_tokens=4096,
            verbose=False
        )
    
    llm = Llama(
        model_path=cfg["path"],
        chat_handler=chat_handler,
        n_gpu_layers=cfg.get("n_gpu_layers", -1),
        n_ctx=cfg.get("n_ctx", 8192),
        verbose=False
    )
    current_model = llm
    current_model_name = model_name
    return llm

# --- FastAPI 接口 ---
app = FastAPI(title="Llama Flex Server")

class ChatRequest(BaseModel):
    model: str
    messages: List[Dict[str, Any]]
    max_tokens: Optional[int] = 2048  # 默认 2048，不再戛然而止
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    stream: Optional[bool] = True    # 默认开启流式

@app.get("/v1/models")
async def list_models():
    return {"data": [{"id": name} for name in models_config.keys()]}

async def generate_stream(request: ChatRequest):
    """流式生成器核心逻辑"""
    global unload_task
    
    # 1. 确保模型已加载
    async with model_lock:
        llm = load_model(request.model)
    
    start_time = time.time()
    completion_tokens = 0
    prompt_tokens = 0

    # 2. 调用 llama-cpp-python 的流式生成
    # 使用 partial 在执行器中运行同步生成器，防止阻塞主线程
    loop = asyncio.get_running_loop()
    gen = functools.partial(
        llm.create_chat_completion,
        messages=request.messages,
        max_tokens=request.max_tokens,
        temperature=request.temperature,
        top_p=request.top_p,
        stream=True
    )
    
    response_iter = await loop.run_in_executor(None, gen)

    try:
        for chunk in response_iter:
            completion_tokens += 1
            # 这里的 chunk 已经是 OpenAI 格式
            yield f"data: {json.dumps(chunk)}\n\n"
        
        yield "data: [DONE]\n\n"
        
        # 3. 计算统计数据
        elapsed = time.time() - start_time
        speed = completion_tokens / elapsed if elapsed > 0 else 0
        print(f"\n[后端] \033[34m流式推理完成 | 耗时: {elapsed:.2f}s | 生成tokens: {completion_tokens} | 速度: {speed:.2f} tokens/s\033[0m", flush=True)

        # 4. 启动自动卸载倒计时
        if unload_task:
            unload_task.cancel()
        unload_task = asyncio.create_task(schedule_unload_with_countdown())

    except Exception as e:
        print(f"\n[后端] 流式传输中断: {str(e)}")

@app.post("/v1/chat/completions")
async def chat_completion(request: ChatRequest):
    # 统一返回流式响应，Open WebUI 能够很好地处理
    return StreamingResponse(generate_stream(request), media_type="text/event-stream")

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=10000, log_level="warning")