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
echo 如果弹出权限请求窗口，请点击"是"
echo.

:: 切换到脚本所在目录
cd /d "%~dp0"

:: 运行 PowerShell 脚本
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0install-openclaw.ps1\"' -Verb RunAs"

exit
