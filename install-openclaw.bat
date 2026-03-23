@echo off
chcp 65001 >nul
:: OpenClaw Windows Quick Install Script
:: Run as Administrator

echo.
echo ========================================
echo   OpenClaw Windows Auto Installer
echo ========================================
echo.

:: Check admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    pause
    exit /b 1
)

:: Download Node.js
echo [1/3] Downloading Node.js LTS...
set NODE_URL=https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi
set NODE_MSI=%TEMP%\node-install.msi
powershell -Command "Invoke-WebRequest -Uri '%NODE_URL%' -OutFile '%NODE_MSI%' -UseBasicParsing"

:: Install Node.js
echo [2/3] Installing Node.js...
msiexec /i "%NODE_MSI%" /qn /norestart

:: Wait for installation
timeout /t 10 /nobreak >nul

:: Refresh PATH
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSTEM_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%b"
set "PATH=%SYSTEM_PATH%;%USER_PATH%"

:: Install OpenClaw
echo [3/3] Installing OpenClaw...
npm install -g npm@latest
npm install -g openclaw@latest

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo   Access: http://localhost:18789
echo   Config: %USERPROFILE%\.openclaw\openclaw.json
echo.
echo   Run 'openclaw gateway start' to start
echo.

:: Create desktop shortcut
echo @echo off > "%USERPROFILE%\Desktop\Start-OpenClaw.bat"
echo title OpenClaw Gateway >> "%USERPROFILE%\Desktop\Start-OpenClaw.bat"
echo openclaw gateway start >> "%USERPROFILE%\Desktop\Start-OpenClaw.bat"
echo pause >> "%USERPROFILE%\Desktop\Start-OpenClaw.bat"

echo Desktop shortcut created!
echo.
pause
