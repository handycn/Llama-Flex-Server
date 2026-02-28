@echo off
title AI 服务一键启动 (分屏终极版)
setlocal enabledelayedexpansion

:: --- 路径配置 (请修改为你的实际路径) ---
set "BACKEND_DIR=C:\path\to\llama-cpp-python"
set "BACKEND_PYTHON=C:\path\to\llama-cpp-python\venv\Scripts\python.exe"
set "BACKEND_SCRIPT=C:\path\to\llama-cpp-python\flex_server.py"

set "FRONTEND_DIR=C:\path\to\OpenWebUI"
set "FRONTEND_EXE=C:\path\to\OpenWebUI\venv\Scripts\open-webui.exe"
set "FRONTEND_DATA=C:\path\to\OpenWebUI\data"

:: ========== Google Drive 集成配置 ==========
set "ENABLE_GOOGLE_DRIVE_INTEGRATION=true"
set "GOOGLE_DRIVE_CLIENT_ID=你的client_id"      :: 请替换为你的实际 Client ID
set "GOOGLE_DRIVE_API_KEY=你的api_key"          :: 请替换为你的实际 API Key
:: ==========================================

:: 1. 环境清理与目录强制检查
echo [1/3] 正在清理残留进程...
taskkill /f /t /im python.exe >nul 2>&1
taskkill /f /t /im open-webui.exe >nul 2>&1
if not exist "%FRONTEND_DATA%" mkdir "%FRONTEND_DATA%"

:: 2. 检查 Windows Terminal
where wt >nul 2>&1
if %errorlevel% neq 0 (
    echo [提示] 未检测到 Windows Terminal，使用普通模式启动...
    start "AI 后端" cmd /k "cd /d "%BACKEND_DIR%" && "%BACKEND_PYTHON%" "%BACKEND_SCRIPT%""
    start "AI 前端" cmd /k "cd /d "%FRONTEND_DIR%" && set OPENAI_API_BASE_URL=http://127.0.0.1:10000/v1 && "%FRONTEND_EXE%" serve"
    goto :SKIP_WT
)

:: 3. 核心黑科技：生成一个绝对不会丢变量的临时启动脚本
:: 这样避开了 wt.exe 处理多重引号导致的闪退和路径丢失
set "LAUNCHER=%TEMP%\webui_start.bat"
echo @echo off > "%LAUNCHER%"
echo set "DATA_DIR=%FRONTEND_DATA%" >> "%LAUNCHER%"
echo set "PYTHONASYNCIODEBUG=0" >> "%LAUNCHER%"
echo set "PYTHONWARNINGS=ignore" >> "%LAUNCHER%"
echo set "OPENAI_API_BASE_URL=http://127.0.0.1:10000/v1" >> "%LAUNCHER%"
echo set "ENABLE_GOOGLE_DRIVE_INTEGRATION=%ENABLE_GOOGLE_DRIVE_INTEGRATION%" >> "%LAUNCHER%"
echo set "GOOGLE_DRIVE_CLIENT_ID=%GOOGLE_DRIVE_CLIENT_ID%" >> "%LAUNCHER%"
echo set "GOOGLE_DRIVE_API_KEY=%GOOGLE_DRIVE_API_KEY%" >> "%LAUNCHER%"
echo cd /d "%FRONTEND_DIR%" >> "%LAUNCHER%"
echo "%FRONTEND_EXE%" serve >> "%LAUNCHER%"

echo [2/3] 正在分屏启动服务 (前端居左，后端居右)...
wt -w 0 nt --title "AI 前端" cmd /k "%LAUNCHER%" ; ^
sp -V --title "AI 后端" cmd /k "cd /d "%BACKEND_DIR%" && "%BACKEND_PYTHON%" "%BACKEND_SCRIPT%""

:SKIP_WT
:: 3. 端口探测与自动退出逻辑
echo [3/3] 正在检测 8080 端口状态...
set /a retry=0
:CHECK_PORT
set /a retry+=1
powershell -Command "$TCPClient = New-Object Net.Sockets.TcpClient; try { $TCPClient.Connect('127.0.0.1', 8080); exit 0 } catch { exit 1 } finally { $TCPClient.Close() }" 

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [成功] 服务已就绪！
    start http://localhost:8080 
    timeout /t 2 /nobreak >nul
    exit 
) else (
    <nul set /p=.
    if !retry! GEQ 40 (
        echo.
        echo [提示] 启动稍慢，强制开启浏览器后退出...
        start http://localhost:8080 
        timeout /t 2 /nobreak >nul
        exit 
    )
    timeout /t 2 /nobreak >nul
    goto CHECK_PORT 
)