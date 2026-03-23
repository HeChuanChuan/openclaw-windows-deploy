@echo off
chcp 65001 >nul
title OpenClaw Windows Installer

echo.
echo ========================================
echo   OpenClaw Windows Auto Installer
echo ========================================
echo.
echo 正在启动 PowerShell 安装脚本...
echo.
echo 请在弹出的窗口中点击"是"允许管理员权限
echo.
echo 如果没有弹出窗口，请手动右键点击
echo install-openclaw.ps1 选择"使用 PowerShell 运行"
echo.

cd /d "%~dp0"

:: 方法1: 直接运行 PowerShell 脚本（请求管理员权限）
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -File \"%~dp0install-openclaw.ps1\"' -Verb RunAs"

echo.
echo 如果上面弹出了新窗口，请在那个窗口中查看安装进度。
echo 如果没有弹出窗口或安装失败，请尝试：
echo   1. 右键点击 install-openclaw.ps1
echo   2. 选择"使用 PowerShell 运行"
echo   3. 点击"是"允许管理员权限
echo.
pause
