# OpenClaw Windows Auto Deploy Script
# Support Windows 10/11
# Usage: Double-click start-install.bat or run in PowerShell

param(
    [switch]$SkipNode,
    [switch]$SkipConfig
)

$ErrorActionPreference = "Stop"

function Write-Step($message) {
    Write-Host "`n[OK] $message" -ForegroundColor Green
}

function Write-Info($message) {
    Write-Host "[..] $message" -ForegroundColor Cyan
}

function Write-Warn($message) {
    Write-Host "[!] $message" -ForegroundColor Yellow
}

function Write-ErrorMsg($message) {
    Write-Host "[X] $message" -ForegroundColor Red
}

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Main {
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Magenta
    Write-Host "    OpenClaw Windows Auto Installer" -ForegroundColor Magenta
    Write-Host "  ========================================" -ForegroundColor Magenta
    Write-Host ""

    if (-not (Test-Administrator)) {
        Write-Warn "Please run as Administrator!"
        Write-Info "Right-click start-install.bat -> Run as administrator"
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Step "Starting OpenClaw deployment..."

    if (-not $SkipNode) {
        Write-Info "Checking Node.js..."
        $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeInstalled) {
            $nodeVersion = node -v
            Write-Step "Node.js already installed: $nodeVersion"
        } else {
            Write-Info "Installing Node.js..."
            Install-NodeJS
        }
    }

    Write-Info "Installing OpenClaw..."
    Install-OpenClaw

    if (-not $SkipConfig) {
        Write-Info "Initializing configuration..."
        Initialize-OpenClaw
    }

    Write-Info "Creating desktop shortcut..."
    Create-Shortcut

    Write-Step "Deployment complete!"
    Write-Host ""
    Write-Info "Access URL: http://localhost:18789"
    Write-Info "Config file: $env:USERPROFILE\.openclaw\openclaw.json"
    Write-Info "Desktop shortcut: Start-OpenClaw.bat"
    Write-Host ""
    Read-Host "Press Enter to exit"
}

function Install-NodeJS {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Info "Using winget to install Node.js LTS..."
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        Refresh-Path
    } else {
        Write-Info "Downloading Node.js installer..."
        $nodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
        $nodeMsi = "$env:TEMP\node-install.msi"

        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeMsi -UseBasicParsing
            Write-Info "Running Node.js installer..."
            Start-Process msiexec.exe -ArgumentList "/i `"$nodeMsi`" /qn" -Wait
        } catch {
            Write-ErrorMsg "Node.js installation failed: $_"
            Write-Info "Please download manually: https://nodejs.org/"
            Read-Host "Press Enter to exit"
            exit 1
        }
    }

    Refresh-Path

    $nodeCheck = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCheck) {
        Write-Step "Node.js installed successfully: $(node -v)"
    } else {
        Write-Warn "Node.js installed. Please restart terminal and run again."
        Read-Host "Press Enter to exit"
        exit 0
    }
}

function Refresh-Path {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = $machinePath + ";" + $userPath
}

function Install-OpenClaw {
    Write-Info "Installing OpenClaw via npm..."

    npm install -g npm@latest 2>&1 | Out-Null
    npm install -g openclaw@latest

    $openclawCheck = Get-Command openclaw -ErrorAction SilentlyContinue
    if ($openclawCheck) {
        Write-Step "OpenClaw installed successfully"
    } else {
        Write-ErrorMsg "OpenClaw installation failed"
        Read-Host "Press Enter to exit"
        exit 1
    }
}

function Initialize-OpenClaw {
    $openclawDir = "$env:USERPROFILE\.openclaw"

    if (-not (Test-Path $openclawDir)) {
        New-Item -ItemType Directory -Path $openclawDir -Force | Out-Null
    }

    Write-Info "Please follow the prompts to complete OpenClaw configuration..."
    Write-Host ""
    openclaw configure
}

function Create-Shortcut {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $batPath = "$desktopPath\Start-OpenClaw.bat"

    $batContent = "@echo off`ntitle OpenClaw Gateway`necho Starting OpenClaw Gateway...`necho.`nopenclaw gateway start`npause"

    $batContent | Out-File -FilePath $batPath -Encoding ASCII
    Write-Step "Desktop shortcut created"
}

Main
