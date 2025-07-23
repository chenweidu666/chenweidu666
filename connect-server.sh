#!/bin/bash

echo "🚀 连接腾讯云服务器 - 小皮球"
echo "服务器信息："
echo "  IP: 101.34.232.12"
echo "  用户名: ubuntu"
echo "  系统: Ubuntu Server 24.04 LTS"
echo ""

# 检查 SSH 密钥
if [ -f ~/.ssh/id_rsa ]; then
    echo "✅ 检测到 SSH 密钥，使用密钥登录"
    ssh ubuntu@101.34.232.12
else
    echo "🔑 未检测到 SSH 密钥，使用密码登录"
    echo "请确保已设置服务器密码"
    ssh ubuntu@101.34.232.12
fi 