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

:: 以管理员权限运行 PowerShell 脚本
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0install-openclaw.ps1'"

pause
