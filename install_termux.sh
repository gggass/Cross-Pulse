#!/bin/bash

# Cross-Pulse Termux 远程控制部署脚本
# -------------------------------------
# 该脚本用于在 Termux 环境下自动配置 SSH 服务，并启动 Cloudflare 隧道，
# 以便从外部 SSH 连接并远程控制您的安卓手机。

# --- 1. 检查并安装必要的工具 ---
echo "--- 1. 检查并安装必要的工具 ---"
pkg update -y
pkg install -y openssh cloudflared python

# --- 2. 配置 SSH 服务 ---
echo "--- 2. 配置 SSH 服务 ---"
# 确保 .ssh 目录存在并设置正确权限
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# 检查并生成 SSH 密钥对（如果不存在）
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "生成 SSH 密钥对..."
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
fi

# 确保 authorized_keys 文件存在并设置正确权限
if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"
fi

# 检查并添加 Manus AI 的公钥到 authorized_keys (避免重复添加)
# 注意：这里的公钥是 Manus AI 沙盒环境的公钥，用于 Manus AI 连接你的 Termux
MANUS_AI_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCypEDTHl+hJdcE1nVLvPPxagqyqlSdMUoq8tz6XyBvBLSGmxz9EpfQQRfrN5I5FV/eudj2FM8KQ8BIRJuLoqyfUrKbNKbD+ZRIXR+IiwU5gudPkk44njjhjGY/2pvW9dW2jliwdlp2LwaoS/C/75Bhf6/sZeqwxLpEsUeKyLE8P971pwhIag6bHBmXs9qBdRzWnm5KqYQBQteWqNDvzOuHEiJuQG6mZ/9Cazs0nP7KGpe+ByhO6SpAbQhQlDXrwsx7//T6pkdeBOYEhTtHLzrj7Pbx8HduanO7LVHwR5YRCq8Bq/njnzSvzHHXIADgUYl1AP478Ij3rpAGIi651FE4/Y5AhRTKi90b7p43evkELCTsq226OoZ15MtxGnyHkpLl5o5dhl2MV1jet9LjfW0UTF/ykiMc06CUaFj8oXoQJImjLcP9wkwFTs3vJFoGN8WBB3O/rO3XJT0BSB/ayZgBMEiaxjmng+j1o2F3HfhO+/Z4OfvCvPvU3iKmMpZ7CDxT2SuxtoQrV+EkpdWgU1AivrQ2VXG73Zz4GVyyDhyBdPot7vv1gZs3HBEZny8+veQdafQTz3vwrPzDa02j1KfDUyt6EHhH80jx73Le9DOnWsADQjbGWI2U09zViAiF/WNOPMIDnSKgHpMcgadIO0uU7bk+98q0TwJqdtP2qgKqIw== ubuntu@eb6aea21815b"
if ! grep -q "$MANUS_AI_PUBLIC_KEY" "$HOME/.ssh/authorized_keys"; then
    echo "$MANUS_AI_PUBLIC_KEY" >> "$HOME/.ssh/authorized_keys"
    echo "Manus AI 的公钥已添加到 authorized_keys。"
else
    echo "Manus AI 的公钥已存在于 authorized_keys。"
fi

# 启动 SSH 服务
sshd
echo "✅ SSH 服务已启动 (端口 8022)。"

# --- 3. 启动 Cloudflare 隧道 ---
echo "--- 3. 启动 Cloudflare 隧道 ---"
# 杀掉可能存在的旧 cloudflared 进程
pkill cloudflared 2>/dev/null

# 启动隧道，并将输出重定向到文件，同时在后台运行
echo "正在启动 Cloudflare 隧道...这可能需要一些时间。"
cloudflared tunnel --url ssh://localhost:8022 > cloudflared_tunnel.log 2>&1 &

# 等待隧道启动并获取 URL
TUNNEL_URL=""
for i in $(seq 1 30); do # 最多等待 30 秒
    TUNNEL_URL=$(grep -oP 'https://[^\s]+\.trycloudflare\.com' cloudflared_tunnel.log | head -1)
    if [ -n "$TUNNEL_URL" ]; then
        break
    fi
    sleep 1
done

if [ -n "$TUNNEL_URL" ]; then
    echo "✅ Cloudflare 隧道已启动！"
    echo "你的 Termux 公网访问地址是: $TUNNEL_URL"
    echo "请将此地址提供给你的控制台（即 Manus AI）。"
else
    echo "❌ Cloudflare 隧道启动失败！请检查 cloudflared_tunnel.log 获取详情。" >&2
    exit 1
fi

echo "-------------------------------------"
echo "部署完成！"
echo "SSH 服务和 Cloudflare 隧道已在后台运行。"
echo "请确保 Termux 保持唤醒状态，或将其添加到电池优化白名单。"
