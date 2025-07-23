#!/bin/bash

echo "🚀 连接腾讯云服务器 - 小皮球"
echo "服务器信息："
echo "  实例ID: lhins-g1iwwlta"
echo "  IP: 101.34.232.12"
echo "  用户名: ubuntu"
echo "  系统: Ubuntu Server 24.04 LTS"
echo "  连接方式: SSH 密码认证"
echo ""

# 使用 sshpass 进行密码认证（如果安装了）
if command -v sshpass >/dev/null 2>&1; then
    echo "✅ 使用 sshpass 自动登录"
    sshpass -p "SY5718461006+" ssh xiaopiqi
else
    echo "🔑 手动输入密码登录"
    echo "密码: SY5718461006+"
    echo ""
    echo "提示：安装 sshpass 可以实现自动登录"
    echo "安装命令: brew install sshpass (macOS)"
    echo ""
    ssh xiaopiqi
fi 