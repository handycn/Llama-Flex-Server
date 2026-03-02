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
            print(f"\r\033[K\033[33m[系统] 模型睡觉去了...\033[0m")
            # 1. 执行 llama-cpp 的内部清理
            current_model.close() 
            # 2. 显式销毁对象
            temp_model = current_model
            current_model = None 
            current_model_name = None
            del temp_model # 强制销毁局部引用
        except Exception as e:
            print(f"卸载异常: {e}")
        
    # 3. 连续执行垃圾回收
    gc.collect()
    # 4. 给 Windows 文件系统一点点“反应时间” (可选，仅在报占用时加)
    # time.sleep(0.1)

async def schedule_unload_with_countdown():
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
    max_tokens: Optional[int] = 4096 
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    stream: Optional[bool] = True

@app.get("/v1/models")
async def list_models():
    return {"data": [{"id": name} for name in models_config.keys()]}

async def generate_stream(request: ChatRequest):
    global unload_task, current_model
    
    async with model_lock:
        llm = load_model(request.model)
    
    print(f"\n[后端] 开始流式推理: {request.model}...", flush=True)
    start_time = time.time()
    completion_tokens = 0

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
            yield f"data: {json.dumps(chunk)}\n\n"
        
        yield "data: [DONE]\n\n"
        
        elapsed = time.time() - start_time
        speed = completion_tokens / elapsed if elapsed > 0 else 0
        
        # --- 健壮性修复：处理属性可能是方法的情况 ---
        kv_used = llm.n_tokens
        if callable(kv_used): kv_used = kv_used()
        
        kv_total = llm.n_ctx
        if callable(kv_total): kv_total = kv_total()
        
        kv_pct = (kv_used / kv_total) * 100 if kv_total > 0 else 0

        print(f"[后端] \033[34m流式推理完成 | 耗时: {elapsed:.2f}s | 生成tokens: {completion_tokens} | 速度: {speed:.2f} t/s | KV Cache: {kv_used}/{kv_total} ({kv_pct:.1f}%)\033[0m", flush=True)

        if unload_task:
            unload_task.cancel()
        unload_task = asyncio.create_task(schedule_unload_with_countdown())

    except Exception as e:
        print(f"\n[后端] 流式传输中断: {str(e)}")

@app.post("/v1/chat/completions")
async def chat_completion(request: ChatRequest):
    global unload_task
    
    if request.stream:
        return StreamingResponse(generate_stream(request), media_type="text/event-stream")
    else:
        async with model_lock:
            llm = load_model(request.model)
        
        print(f"\n[后端] 开始非流式推理: {request.model}...", flush=True)
        start_time = time.time()
        loop = asyncio.get_running_loop()
        completion = await loop.run_in_executor(None, functools.partial(
            llm.create_chat_completion,
            messages=request.messages,
            max_tokens=request.max_tokens,
            temperature=request.temperature,
            top_p=request.top_p,
            stream=False
        ))
        
        elapsed = time.time() - start_time
        completion_tokens = completion['usage']['completion_tokens']
        speed = completion_tokens / elapsed if elapsed > 0 else 0
        
        # --- 健壮性修复：处理属性可能是方法的情况 ---
        kv_used = llm.n_tokens
        if callable(kv_used): kv_used = kv_used()
        
        kv_total = llm.n_ctx
        if callable(kv_total): kv_total = kv_total()
        
        kv_pct = (kv_used / kv_total) * 100 if kv_total > 0 else 0

        print(f"[后端] \033[35m非流式推理完成 | 耗时: {elapsed:.2f}s | 生成tokens: {completion_tokens} | 速度: {speed:.2f} t/s | KV Cache: {kv_used}/{kv_total} ({kv_pct:.1f}%)\033[0m", flush=True)

        if unload_task:
            unload_task.cancel()
        unload_task = asyncio.create_task(schedule_unload_with_countdown())
        
        return completion

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=10000, log_level="warning")