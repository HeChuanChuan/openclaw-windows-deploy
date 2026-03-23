# OpenClaw Windows 自动部署脚本
# 支持 Windows 10/11
# 使用方法：右键以管理员身份运行

param(
    [switch]$SkipNode,
    [switch]$SkipConfig
)

$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Step($message) {
    Write-ColorOutput Green "`n[✓] $message"
}

function Write-Info($message) {
    Write-ColorOutput Cyan "[i] $message"
}

function Write-Warn($message) {
    Write-ColorOutput Yellow "[!] $message"
}

# 检查管理员权限
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 主函数
function Main {
    Write-ColorOutput Magenta @"

  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
  ██░▄▄▄░██░▄▄░██░▄▄▄██░▀██░██░▄▄▀██░████░▄▄▀██░███░██
  ██░███░██░▀▀░██░▄▄▄██░█░█░██░█████░████░▀▀░██░█░█░██
  ██░▀▀▀░██░█████░▀▀▀██░██▄░██░▀▀▄██░▀▀░█░██░██▄▀▄▀▄██
  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
                    🦞 OpenClaw Windows 部署脚本 🦞

"@

    # 检查管理员权限
    if (-not (Test-Administrator)) {
        Write-Warn "请以管理员身份运行此脚本！"
        Write-Info "右键点击脚本 -> '以管理员身份运行'"
        pause
        exit 1
    }

    Write-Step "开始部署 OpenClaw..."

    # 1. 检查并安装 Node.js
    if (-not $SkipNode) {
        Write-Info "检查 Node.js..."
        $nodeVersion = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeVersion) {
            Write-Step "Node.js 已安装: $(node -v)"
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

    # 4. 启动服务
    Write-Info "启动 OpenClaw Gateway..."
    Start-OpenClaw

    Write-Step "部署完成！"
    Write-Info "访问地址: http://localhost:18789"
    Write-Info "配置文件: $env:USERPROFILE\.openclaw\openclaw.json"
}

# 安装 Node.js
function Install-NodeJS {
    # 使用 winget 安装
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "使用 winget 安装 Node.js LTS..."
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    } else {
        # 下载安装包
        Write-Info "下载 Node.js 安装包..."
        $nodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
        $nodeMsi = "$env:TEMP\node-install.msi"

        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeMsi -UseBasicParsing
        Write-Info "运行 Node.js 安装程序..."
        Start-Process msiexec.exe -ArgumentList "/i `"$nodeMsi`" /qn" -Wait

        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    # 验证安装
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Step "Node.js 安装成功: $(node -v)"
    } else {
        Write-Warn "Node.js 安装完成，请重新打开终端后继续"
        pause
        exit 0
    }
}

# 安装 OpenClaw
function Install-OpenClaw {
    Write-Info "使用 npm 全局安装 OpenClaw..."

    # 更新 npm
    npm install -g npm@latest

    # 安装 OpenClaw
    npm install -g openclaw@latest

    # 验证安装
    if (Get-Command openclaw -ErrorAction SilentlyContinue) {
        Write-Step "OpenClaw 安装成功: $(openclaw --version)"
    } else {
        throw "OpenClaw 安装失败"
    }
}

# 初始化配置
function Initialize-OpenClaw {
    $openclawDir = "$env:USERPROFILE\.openclaw"

    # 创建目录
    if (-not (Test-Path $openclawDir)) {
        New-Item -ItemType Directory -Path $openclawDir -Force | Out-Null
    }

    # 运行初始化向导
    Write-Info "运行 OpenClaw 配置向导..."
    Write-Info "请按照提示完成配置..."
    openclaw configure
}

# 启动 OpenClaw
function Start-OpenClaw {
    Write-Info "启动 Gateway 服务..."

    # 创建启动脚本
    $startScript = @"
@echo off
title OpenClaw Gateway
echo Starting OpenClaw Gateway...
openclaw gateway start
pause
"@

    $startScript | Out-File -FilePath "$env:USERPROFILE\Desktop\Start-OpenClaw.bat" -Encoding ASCII

    # 启动服务
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "openclaw gateway start"
}

# 执行主函数
Main
