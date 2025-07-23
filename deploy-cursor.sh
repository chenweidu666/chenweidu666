#!/bin/bash

set -e

echo "🚀 Cursor 远程开发部署脚本..."

# 检查是否在远程环境中
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
    echo "❌ 请在 Cursor 的远程 SSH 环境中运行此脚本"
    exit 1
fi

echo "✅ 检测到远程 SSH 环境"

# 检查 Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "📦 安装 Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 检查 Git
if ! command -v git >/dev/null 2>&1; then
    echo "📦 安装 Git..."
    sudo apt update
    sudo apt install -y git
fi

# 检查 Docker
if ! command -v docker >/dev/null 2>&1; then
    echo "📦 安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    newgrp docker
fi

# 检查 Docker Compose
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "📦 安装 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 创建项目目录
PROJECT_DIR="/home/$USER/wardrobe"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

echo "📁 项目目录: $PROJECT_DIR"

# 检查是否已有项目文件
if [ ! -f "package.json" ]; then
    echo "📥 从本地复制项目文件..."
    echo "请在本地 Cursor 中运行以下命令复制项目文件："
    echo "scp -r ./* $USER@$(hostname -I | awk '{print $1}'):$PROJECT_DIR/"
    echo ""
    echo "或者手动上传项目文件到服务器"
    exit 1
fi

# 安装依赖
echo "📦 安装项目依赖..."
if [ -f "backend/package.json" ]; then
    cd backend
    npm install --production
    cd ..
fi

if [ -f "frontend/package.json" ]; then
    cd frontend
    npm install
    npm run build
    cd ..
fi

# 创建 Docker 配置
echo "🐳 创建 Docker 配置..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  wardrobe-app:
    build: .
    ports:
      - "3000:3000"
      - "3001:3001"
    environment:
      - NODE_ENV=production
    volumes:
      - ./backend/uploads:/app/backend/uploads
      - ./backend/wardrobe.db:/app/backend/wardrobe.db
    restart: unless-stopped
EOF

cat > Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# 安装依赖
COPY backend/package*.json ./backend/
RUN cd backend && npm install --production

# 复制应用文件
COPY . .

# 暴露端口
EXPOSE 3000 3001

# 启动应用
CMD ["./start.sh"]
EOF

cat > start.sh << 'EOF'
#!/bin/bash
cd backend
npm start &
cd ../frontend
npx serve -s . -l 3000 &
wait
EOF

chmod +x start.sh

# 启动服务
echo "🚀 启动服务..."
docker-compose up -d --build

echo "✅ 部署完成！"
echo "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):3000"
echo "📋 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down" 