@echo off
chcp 65001 >nul
title 像素田园 · 部署
python "%~dp0deploy.py"
set RC=%ERRORLEVEL%
echo.
if %RC% neq 0 (
    echo [FAILED] 部署失败 exit %RC%
) else (
    echo [OK] 全部完成
)
echo.
pause
