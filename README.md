# 📱 Cross-Pulse: 手机远程控制中心 (Termux Edition)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Language-Python3.12+-blue.svg)](https://www.python.org/)

**Cross-Pulse** 是一款极致轻量级的工具，旨在通过安全的 SSH 隧道，实现对安卓手机 Termux 环境的远程控制。它让你能够像操作远程服务器一样，管理你的手机，执行命令，甚至操控手机应用。

---

## ✨ 核心特性

- **🚀 极速部署**：一键脚本即可在 Termux 中完成所有配置，无需复杂手动步骤。
- **🔒 安全连接**：基于 SSH 公私钥认证，确保只有授权的设备才能连接。
- **🌐 内网穿透**：利用 Cloudflare Tunnel 轻松穿透内网，无需公网 IP 即可从任何地方远程访问你的 Termux。
- **🤖 远程指令**：通过 SSH 连接，你可以远程执行任何 Termux 命令，管理文件，安装软件，甚至启动安卓应用。
- **轻量高效**：纯脚本和现有工具集成，不引入额外的 C++ 编译负担。

## 🛠️ 工作原理

Cross-Pulse 的核心在于利用 Termux 提供的 Linux 环境和 Cloudflare Tunnel 的内网穿透能力：

1.  **Termux SSH 服务**：在 Termux 中启动 OpenSSH 服务，监听本地 8022 端口，允许通过 SSH 协议进行连接。
2.  **Cloudflare Tunnel**：`cloudflared` 工具在 Termux 中运行，将本地的 SSH 端口 (8022) 安全地映射到 Cloudflare 的全球网络上，生成一个公网可访问的 HTTPS 域名。
3.  **远程控制**：外部设备（例如 Manus AI 沙盒环境）通过 SSH 客户端连接到 Cloudflare Tunnel 提供的公网域名，即可建立与 Termux 的安全连接，并执行远程命令。

## 🚀 快速开始

### 环境要求
- **安卓手机**：已安装 Termux 应用。
- **网络连接**：手机需要有稳定的互联网连接。

### 部署与运行 (手机端)

1.  **打开 Termux**：在你的安卓手机上启动 Termux 应用。

2.  **下载并运行部署脚本**：
    ```bash
    # 下载脚本
    curl -O https://raw.githubusercontent.com/gggass/Cross-Pulse/main/install_termux.sh

    # 赋予执行权限
    chmod +x install_termux.sh

    # 运行脚本
    ./install_termux.sh
    ```

3.  **获取公网地址**：脚本运行成功后，会输出一个 `https://xxxx.trycloudflare.com` 格式的公网访问地址。请将此地址提供给你的远程控制端（例如 Manus AI）。

4.  **保持运行**：为了维持远程连接，请确保 Termux 应用保持在前台运行，或将其添加到手机的电池优化白名单中，防止系统杀死 `cloudflared` 进程。

### 远程连接 (控制端)

一旦你获得了手机端提供的公网地址，你就可以从任何支持 SSH 的设备（如 Linux/macOS 终端、Windows WSL 或 Manus AI 沙盒）进行连接：

```bash
# 假设你的 Termux 用户名是 'u0_aXXX' (通常是默认的)
# 假设你的公网地址是 'https://your-tunnel-id.trycloudflare.com'

# 首先，在控制端启动 cloudflared access 代理
# cloudflared access tcp --hostname your-tunnel-id.trycloudflare.com --url localhost:2222
# (注意：这里的 localhost:2222 是控制端本地映射的端口，可以自定义)

# 然后，通过 SSH 连接到本地映射的端口
# ssh -p 2222 u0_aXXX@localhost

# 或者，如果你的控制端也安装了 cloudflared，可以直接连接
# ssh -o ProxyCommand="cloudflared access ssh --hostname %h" u0_aXXX@your-tunnel-id.trycloudflare.com
```

**注意**：具体的 SSH 用户名可以在 Termux 中通过 `whoami` 命令查看。

## 📜 文件说明
- `install_termux.sh`: 手机端一键部署脚本，负责安装依赖、配置 SSH 和启动 Cloudflare 隧道。
- `README.md`: 项目介绍与使用指南。

## 🤝 贡献指南
欢迎提交 Issue 或 Pull Request 来增加更多便捷功能或优化脚本。

## 📄 开源协议
本项目采用 MIT 协议开源。

---
由 **gggass** 精心打造。
