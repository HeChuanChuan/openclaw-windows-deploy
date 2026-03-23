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

### ⭐ 方法一：双击运行（最简单）

1. 下载整个项目或 `start-install.bat` 和 `install-openclaw.ps1`
2. **双击 `start-install.bat`**
3. 点击「是」允许管理员权限
4. 等待安装完成

### 方法二：PowerShell 运行

1. 右键点击 `install-openclaw.ps1`
2. 选择 **「使用 PowerShell 运行」**
3. 点击「是」允许管理员权限

### 方法三：命令行运行

```powershell
# 以管理员身份打开 PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\install-openclaw.ps1
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
