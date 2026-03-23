@echo off
chcp 65001 >nul
title OpenClaw Windows Installer

echo.
echo ========================================
echo   OpenClaw Windows Auto Installer
echo ========================================
echo.
echo Starting PowerShell installation script...
echo.
echo Please click "Yes" if a permission window pops up.
echo.

cd /d "%~dp0"

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -File \"%~dp0install-openclaw.ps1\"' -Verb RunAs"

echo.
echo If a new window appeared, please check the progress there.
echo If nothing happened, please:
echo   1. Right-click install-openclaw.ps1
echo   2. Select "Run with PowerShell"
echo   3. Click "Yes" to allow admin privileges
echo.
pause
