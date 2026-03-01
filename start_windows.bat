@echo off
title AI 服务一键启动 (安全备份版)
setlocal enabledelayedexpansion

:: --- 路径配置 ---
set "BACKEND_DIR=T:\AICG\llama-cpp-python"
set "BACKEND_PYTHON=T:\AICG\llama-cpp-python\venv\Scripts\python.exe"
set "BACKEND_SCRIPT=T:\AICG\llama-cpp-python\flex_server.py"

set "FRONTEND_DIR=T:\AICG\OpenWebUI"
set "FRONTEND_EXE=T:\AICG\OpenWebUI\venv\Scripts\open-webui.exe"
set "FRONTEND_DATA=T:\AICG\OpenWebUI\data"
set "BACKUP_DIR=T:\AICG\OpenWebUI\backups"

:: ========== Google Drive 集成配置 ==========
set "ENABLE_GOOGLE_DRIVE_INTEGRATION=true"
set "GOOGLE_DRIVE_CLIENT_ID=你的client_id"      :: 请替换为你的实际 Client ID
set "GOOGLE_DRIVE_API_KEY=你的api_key"          :: 请替换为你的实际 API Key
:: ==========================================

:: 1. 环境清理
echo [1/4] 正在清理残留进程...
taskkill /f /t /im python.exe >nul 2>&1
taskkill /f /t /im open-webui.exe >nul 2>&1

:: 2. 数据库自动备份逻辑
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
if not exist "%FRONTEND_DATA%" mkdir "%FRONTEND_DATA%"

:: 获取当前日期 (兼容不同系统格式)
for /f "tokens=1-3 delims=/- " %%a in ('echo %DATE%') do (
    set "YYYY=%%c"
    set "MM=%%a"
    set "DD=%%b"
)
set "BACKUP_DATE=%YYYY%%MM%%DD%"

echo [2/4] 正在备份数据库...
if exist "%FRONTEND_DATA%\webui.db" (
    copy /y "%FRONTEND_DATA%\webui.db" "%BACKUP_DIR%\webui_%BACKUP_DATE%.db" >nul
    echo [成功] 已备份至: backups\webui_%BACKUP_DATE%.db
    
    :: 保留最近7天备份，自动清理旧的
    if exist "%BACKUP_DIR%\*.db" (
        forfiles /p "%BACKUP_DIR%" /m "webui_*.db" /d -7 /c "cmd /c echo [清理] 删除过期备份 @file & del @path" 2>nul
    )
) else (
    echo [提示] 尚未发现数据库文件，跳过备份。
)

:: 3. 生成启动脚本
set "LAUNCHER=%TEMP%\webui_start.bat"
echo @echo off > "%LAUNCHER%"
echo set "DATA_DIR=%FRONTEND_DATA%" >> "%LAUNCHER%"
echo set "PYTHONASYNCIODEBUG=0" >> "%LAUNCHER%"
echo set "PYTHONWARNINGS=ignore" >> "%LAUNCHER%"
echo set "LOG_LEVEL=error" >> "%LAUNCHER%"
echo set "ENABLE_GOOGLE_DRIVE_INTEGRATION=%ENABLE_GOOGLE_DRIVE_INTEGRATION%" >> "%LAUNCHER%"
echo set "GOOGLE_DRIVE_CLIENT_ID=%GOOGLE_DRIVE_CLIENT_ID%" >> "%LAUNCHER%"
echo set "GOOGLE_DRIVE_API_KEY=%GOOGLE_DRIVE_API_KEY%" >> "%LAUNCHER%"
:: 核心修复：锁定 127.0.0.1 绕过 Windows 域名安全限制
echo set "HOST=127.0.0.1" >> "%LAUNCHER%"
echo set "PORT=8080" >> "%LAUNCHER%"
echo set "WEBUI_URL=http://127.0.0.1:8080" >> "%LAUNCHER%"
echo cd /d "%FRONTEND_DIR%" >> "%LAUNCHER%"
echo "%FRONTEND_EXE%" serve >> "%LAUNCHER%"

echo [3/4] 正在分屏启动服务...

:: 检查 Windows Terminal 是否可用
where wt >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    wt -w 0 nt --title "AI 前端" cmd /k "%LAUNCHER%" ; ^
    sp -V --title "AI 后端" cmd /k "cd /d "%BACKEND_DIR%" && "%BACKEND_PYTHON%" "%BACKEND_SCRIPT%""
) else (
    echo [提示] 使用传统窗口模式启动...
    start "AI 前端" cmd /k "%LAUNCHER%"
    start "AI 后端" cmd /k "cd /d "%BACKEND_DIR%" && "%BACKEND_PYTHON%" "%BACKEND_SCRIPT%""
)

:: 4. 端口探测
echo [4/4] 正在检测 127.0.0.1:8080 端口...
set /a retry=0
:CHECK_PORT
set /a retry+=1
powershell -Command "$TCPClient = New-Object Net.Sockets.TcpClient; try { $TCPClient.Connect('127.0.0.1', 8080); exit 0 } catch { exit 1 } finally { $TCPClient.Close() }"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [完成] 服务已就绪！
    start http://127.0.0.1:8080
    timeout /t 2 /nobreak >nul
    exit
) else (
    <nul set /p=.
    if !retry! GEQ 40 (
        echo.
        echo [超时] 强制开启浏览器...
        start http://127.0.0.1:8080
        exit
    )
    timeout /t 2 /nobreak >nul
    goto CHECK_PORT
)
