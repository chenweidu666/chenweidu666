#!/bin/bash

set -e

echo "🚀 部署到腾讯云 CVM..."

# 检查参数
if [ $# -lt 3 ]; then
    echo "用法: $0 <服务器IP> <用户名> <密钥文件路径>"
    echo "示例: $0 123.456.789.123 ubuntu ~/.ssh/tencent.pem"
    exit 1
fi

SERVER_IP=$1
USERNAME=$2
KEY_FILE=$3

# 检查密钥文件
if [ ! -f "$KEY_FILE" ]; then
    echo "❌ 密钥文件不存在: $KEY_FILE"
    exit 1
fi

# 构建部署包
echo "📦 构建部署包..."
./deploy.sh

# 上传到服务器
echo "📤 上传到服务器..."
scp -i "$KEY_FILE" -r deploy/* $USERNAME@$SERVER_IP:/home/$USERNAME/wardrobe/

# 在服务器上部署
echo "🔧 在服务器上部署..."
ssh -i "$KEY_FILE" $USERNAME@$SERVER_IP << 'EOF'
cd /home/ubuntu/wardrobe

# 安装 Docker (如果未安装)
if ! command -v docker &> /dev/null; then
    echo "📦 安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    newgrp docker
fi

# 安装 Docker Compose (如果未安装)
if ! command -v docker-compose &> /dev/null; then
    echo "📦 安装 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 停止旧容器
docker-compose down || true

# 构建并启动新容器
docker-compose up -d --build

echo "✅ 部署完成！"
echo "🌐 访问地址: http://$SERVER_IP:3000"
EOF

echo "✅ 部署完成！"
echo "🌐 访问地址: http://$SERVER_IP:3000" 