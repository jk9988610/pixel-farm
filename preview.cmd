@echo off
chcp 65001 >nul
setlocal
rem 像素田园 · 本地预览一键启动
rem 双击本文件: 自动选空端口启动 http.server 并打开浏览器
cd /d "%~dp0"

where python >nul 2>nul
if errorlevel 1 (
  echo [ERR] 未找到 python, 请先安装 Python 3 并加入 PATH
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$port=8083; while($true){ $c=New-Object Net.Sockets.TcpClient; try { $c.Connect('127.0.0.1',$port); $c.Close(); $port++ } catch { break } }; Write-Host ('预览地址: http://127.0.0.1:'+$port+'/play.html'); Start-Process ('http://127.0.0.1:'+$port+'/play.html'); python -m http.server $port --directory '.\demo'"

endlocal
