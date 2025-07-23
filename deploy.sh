#!/bin/bash

set -e

echo "🚀 开始部署到腾讯云..."

# 检查环境变量
if [ -z "$TENCENT_SECRET_ID" ] || [ -z "$TENCENT_SECRET_KEY" ]; then
    echo "❌ 请设置腾讯云密钥环境变量："
    echo "export TENCENT_SECRET_ID=你的密钥ID"
    echo "export TENCENT_SECRET_KEY=你的密钥Key"
    exit 1
fi

# 构建前端
echo "📦 构建前端..."
cd frontend
npm run build
cd ..

# 构建后端
echo "📦 构建后端..."
cd backend
npm install --production
cd ..

# 创建部署包
echo "📦 创建部署包..."
DEPLOY_DIR="deploy"
rm -rf $DEPLOY_DIR
mkdir -p $DEPLOY_DIR

# 复制前端构建文件
cp -r frontend/dist $DEPLOY_DIR/frontend

# 复制后端文件
cp -r backend/* $DEPLOY_DIR/backend/
rm -rf $DEPLOY_DIR/backend/node_modules

# 创建启动脚本
cat > $DEPLOY_DIR/start.sh << 'EOF'
#!/bin/bash
cd backend
npm install --production
npm start &
cd ../frontend
npx serve -s . -l 3000 &
wait
EOF

chmod +x $DEPLOY_DIR/start.sh

# 创建 Dockerfile
cat > $DEPLOY_DIR/Dockerfile << 'EOF'
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

# 创建 docker-compose.yml
cat > $DEPLOY_DIR/docker-compose.yml << 'EOF'
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

echo "✅ 部署包已创建在 $DEPLOY_DIR 目录"
echo ""
echo "📋 部署选项："
echo "1. 腾讯云 CVM (云服务器)"
echo "2. 腾讯云 TKE (容器服务)"
echo "3. 腾讯云 SCF (云函数)"
echo ""
echo "请选择部署方式并运行相应的命令" 