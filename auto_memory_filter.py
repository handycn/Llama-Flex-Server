"""
title: Auto Memory Injector
author: You
version: 1.0
description: 自动从本地文件读取记忆并注入系统提示词
"""

import os
from pathlib import Path
from typing import Optional

class Filter:
    def __init__(self):
        # 改成你电脑上 memory.txt 的实际路径
        # 示例路径（根据你的系统选一个）：
        # Windows: self.memory_file = "C:\\Users\\你的用户名\\memory.txt"
        # Mac: self.memory_file = "/Users/你的用户名/memory.txt"
        self.memory_file = "/Users/zhuyanan/Documents/llama-cpp-python/memory.md"
        
    def inlet(self, body: dict, __user__: Optional[dict] = None) -> dict:
        # 读取记忆文件
        try:
            if os.path.exists(self.memory_file):
                with open(self.memory_file, 'r', encoding='utf-8') as f:
                    memory_content = f.read().strip()
                
                if memory_content:
                    # 构建记忆块
                    memory_block = f"\n\n## 用户的长期记忆\n{memory_content}\n"
                    
                    # 查找并注入到系统提示词
                    messages = body.get("messages", [])
                    for i, msg in enumerate(messages):
                        if msg.get("role") == "system":
                            # 如果已有系统提示词，附加在后面
                            body["messages"][i]["content"] += memory_block
                            break
                    else:
                        # 如果没有系统提示词，新建一个
                        body["messages"].insert(0, {
                            "role": "system",
                            "content": memory_block
                        })
        except Exception as e:
            print(f"[Auto Memory] 读取失败: {e}")
            
        return body