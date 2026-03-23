# OpenClaw Windows 自动部署脚本
# 支持 Windows 10/11
# 使用方法：双击 start-install.bat 或在 PowerShell 中运行

param(
    [switch]$SkipNode,
    [switch]$SkipConfig
)

$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-Step($message) {
    Write-Host "`n[OK] $message" -ForegroundColor Green
}

function Write-Info($message) {
    Write-Host "[..] $message" -ForegroundColor Cyan
}

function Write-Warn($message) {
    Write-Host "[!] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[X] $message" -ForegroundColor Red
}

# 检查管理员权限
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 主函数
function Main {
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Magenta
    Write-Host "    OpenClaw Windows Auto Installer" -ForegroundColor Magenta
    Write-Host "  ========================================" -ForegroundColor Magenta
    Write-Host ""

    # 检查管理员权限
    if (-not (Test-Administrator)) {
        Write-Warn "请以管理员身份运行此脚本！"
        Write-Info "右键点击 start-install.bat -> 以管理员身份运行"
        Write-Host ""
        Read-Host "按回车键退出"
        exit 1
    }

    Write-Step "开始部署 OpenClaw..."

    # 1. 检查并安装 Node.js
    if (-not $SkipNode) {
        Write-Info "检查 Node.js..."
        $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeInstalled) {
            $nodeVersion = node -v
            Write-Step "Node.js 已安装: $nodeVersion"
        } else {
            Write-Info "正在安装 Node.js..."
            Install-NodeJS
        }
    }

    # 2. 安装 OpenClaw
    Write-Info "安装 OpenClaw..."
    Install-OpenClaw

    # 3. 初始化配置
    if (-not $SkipConfig) {
        Write-Info "初始化配置..."
        Initialize-OpenClaw
    }

    # 4. 创建启动快捷方式
    Write-Info "创建桌面快捷方式..."
    Create-Shortcut

    Write-Step "部署完成！"
    Write-Host ""
    Write-Info "访问地址: http://localhost:18789"
    Write-Info "配置文件: $env:USERPROFILE\.openclaw\openclaw.json"
    Write-Info "桌面快捷方式: Start-OpenClaw.bat"
    Write-Host ""
    Read-Host "按回车键退出"
}

# 安装 Node.js
function Install-NodeJS {
    # 使用 winget 安装
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Info "使用 winget 安装 Node.js LTS..."
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        Refresh-Path
    } else {
        # 下载安装包
        Write-Info "下载 Node.js 安装包..."
        $nodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
        $nodeMsi = "$env:TEMP\node-install.msi"

        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeMsi -UseBasicParsing
            Write-Info "运行 Node.js 安装程序..."
            Start-Process msiexec.exe -ArgumentList "/i `"$nodeMsi`" /qn" -Wait
        } catch {
            Write-Error "Node.js 安装失败: $_"
            Write-Info "请手动下载安装: https://nodejs.org/"
            Read-Host "按回车键退出"
            exit 1
        }
    }

    # 刷新环境变量
    Refresh-Path

    # 验证安装
    $nodeCheck = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCheck) {
        Write-Step "Node.js 安装成功: $(node -v)"
    } else {
        Write-Warn "Node.js 安装完成，请重新打开终端后继续"
        Read-Host "按回车键退出"
        exit 0
    }
}

# 刷新环境变量
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# 安装 OpenClaw
function Install-OpenClaw {
    Write-Info "使用 npm 全局安装 OpenClaw..."

    # 更新 npm
    npm install -g npm@latest 2>&1 | Out-Null

    # 安装 OpenClaw
    npm install -g openclaw@latest

    # 验证安装
    $openclawCheck = Get-Command openclaw -ErrorAction SilentlyContinue
    if ($openclawCheck) {
        $version = openclaw --version 2>&1
        Write-Step "OpenClaw 安装成功"
    } else {
        Write-Error "OpenClaw 安装失败"
        Read-Host "按回车键退出"
        exit 1
    }
}

# 初始化配置
function Initialize-OpenClaw {
    $openclawDir = "$env:USERPROFILE\.openclaw"

    # 创建目录
    if (-not (Test-Path $openclawDir)) {
        New-Item -ItemType Directory -Path $openclawDir -Force | Out-Null
    }

    Write-Info "请按照提示完成 OpenClaw 配置..."
    Write-Host ""
    openclaw configure
}

# 创建桌面快捷方式
function Create-Shortcut {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $batPath = "$desktopPath\Start-OpenClaw.bat"

    $batContent = @"
@echo off
title OpenClaw Gateway
echo Starting OpenClaw Gateway...
echo.
openclaw gateway start
pause
"@

    $batContent | Out-File -FilePath $batPath -Encoding ASCII
    Write-Step "桌面快捷方式已创建"
}

# 执行主函数
Main
