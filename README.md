# OpenClaw Windows 自动部署脚本

🦞 一键在 Windows 上部署 OpenClaw

## 功能特性

- ✅ 自动检测并安装 Node.js LTS
- ✅ 自动安装 OpenClaw
- ✅ 交互式配置向导
- ✅ 自动启动 Gateway 服务
- ✅ 创建桌面快捷方式

## 系统要求

- Windows 10 或 Windows 11
- 管理员权限

## 使用方法

### 方法一：直接运行（推荐）

1. 下载 `install-openclaw.ps1`
2. 右键点击 -> **以管理员身份运行**
3. 按照提示完成安装

### 方法二：PowerShell 命令行

```powershell
# 以管理员身份打开 PowerShell
# 下载并执行脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-windows-deploy/main/install-openclaw.ps1" -OutFile "install-openclaw.ps1"
Set-ExecutionPolicy Bypass -Scope Process -Force
.\install-openclaw.ps1
```

### 方法三：跳过某些步骤

```powershell
# 跳过 Node.js 安装（已安装时）
.\install-openclaw.ps1 -SkipNode

# 跳过配置向导
.\install-openclaw.ps1 -SkipConfig
```

## 安装后

安装完成后：

1. 访问 http://localhost:18789
2. 配置文件位置：`C:\Users\你的用户名\.openclaw\openclaw.json`
3. 桌面会有 `Start-OpenClaw.bat` 快捷方式

## 常见问题

### Q: 提示"无法运行脚本"

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Q: Node.js 安装后命令不生效

请关闭当前终端，重新打开一个新的终端窗口。

### Q: 如何卸载

```powershell
npm uninstall -g openclaw
```

## 相关链接

- OpenClaw 官网: https://openclaw.ai
- OpenClaw 文档: https://docs.openclaw.ai
- GitHub: https://github.com/openclaw/openclaw

## License

MIT
