#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
SERVER_IP="101.34.232.12"
SERVER_USER="ubuntu"
SERVER_PASSWORD="SY5718461006+"
FRONTEND_PORT="7861"
BACKEND_PORT="7860"

# 显示帮助信息
show_help() {
    echo -e "${CYAN}智能衣柜管理系统 - 统一部署脚本${NC}"
    echo ""
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 [选项]"
    echo ""
    echo -e "${YELLOW}选项:${NC}"
    echo "  build                   构建并启动本地开发环境"
    echo "  deploy                  构建部署包"
    echo "  deploy-cvm [IP] [USER] [KEY] 部署到腾讯云CVM"
    echo "  deploy-tke [CLUSTER] [NS] [REGISTRY] [TAG] 部署到腾讯云TKE"
    echo "  deploy-scf [FUNC] [VER] 部署到腾讯云SCF"
    echo "  deploy-cursor           部署到Cursor远程环境"
    echo "  connect                 连接到服务器"
    echo "  connect-xiaopiqi        连接到小皮球服务器"
    echo "  start                   启动本地服务"
    echo "  stop                    停止本地服务"
    echo "  status                  查看服务状态"
    echo "  logs                    查看服务日志"
    echo "  clean                   清理构建文件"
    echo "  help                    显示此帮助信息"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0 build                 # 构建并启动本地开发"
    echo "  $0 deploy-cvm 123.456.789.123 ubuntu ~/.ssh/key.pem"
    echo "  $0 connect               # 连接到服务器"
    echo ""
}

# 检查依赖
check_dependencies() {
    echo -e "${BLUE}🔍 检查系统依赖...${NC}"
    
    # 检查 Node.js
    if ! command -v node >/dev/null 2>&1; then
        echo -e "${RED}❌ 未检测到 Node.js，请先安装 Node.js (https://nodejs.org/)${NC}"
        exit 1
    fi
    
    # 检查 npm
    if ! command -v npm >/dev/null 2>&1; then
        echo -e "${RED}❌ 未检测到 npm，请先安装 npm (https://nodejs.org/)${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 依赖检查完成${NC}"
}

# 构建本地开发环境
build_local() {
    echo -e "${BLUE}🔨 构建本地开发环境...${NC}"
    
    check_dependencies
    
    # 安装后端依赖
    echo -e "${YELLOW}[后端] 安装依赖...${NC}"
    cd backend
    if [ ! -d "node_modules" ]; then
        npm install
    else
        echo -e "${GREEN}[后端] 已安装依赖，跳过安装。${NC}"
    fi
    cd ..
    
    # 安装前端依赖
    echo -e "${YELLOW}[前端] 安装依赖...${NC}"
    cd frontend
    if [ ! -d "node_modules" ]; then
        npm install
    else
        echo -e "${GREEN}[前端] 已安装依赖，跳过安装。${NC}"
    fi
    cd ..
    
    echo -e "${GREEN}✅ 本地开发环境构建完成${NC}"
}

# 启动本地服务
start_local() {
    echo -e "${BLUE}🚀 启动本地服务...${NC}"
    
    # 检查是否已运行
    if pgrep -f "node.*server.js" > /dev/null; then
        echo -e "${YELLOW}⚠️  后端服务已在运行${NC}"
    else
        echo -e "${YELLOW}[后端] 启动服务...${NC}"
        cd backend
        nohup npm run dev > backend.log 2>&1 &
        BACKEND_PID=$!
        echo $BACKEND_PID > backend.pid
        echo -e "${GREEN}[后端] 已启动，PID: $BACKEND_PID${NC}"
        cd ..
    fi
    
    if pgrep -f "vite" > /dev/null; then
        echo -e "${YELLOW}⚠️  前端服务已在运行${NC}"
    else
        echo -e "${YELLOW}[前端] 启动服务...${NC}"
        cd frontend
        nohup npm run dev > frontend.log 2>&1 &
        FRONTEND_PID=$!
        echo $FRONTEND_PID > frontend.pid
        echo -e "${GREEN}[前端] 已启动，PID: $FRONTEND_PID${NC}"
        cd ..
    fi
    
    echo -e "${GREEN}✅ 本地服务启动完成${NC}"
    echo -e "${CYAN}🌐 访问地址:${NC}"
    echo -e "  前端: ${GREEN}http://localhost:3000${NC}"
    echo -e "  后端: ${GREEN}http://localhost:3001${NC}"
}

# 停止本地服务
stop_local() {
    echo -e "${BLUE}🛑 停止本地服务...${NC}"
    
    # 停止后端
    if [ -f "backend/backend.pid" ]; then
        BACKEND_PID=$(cat backend/backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            kill $BACKEND_PID
            echo -e "${GREEN}[后端] 已停止，PID: $BACKEND_PID${NC}"
        fi
        rm -f backend/backend.pid
    fi
    
    # 停止前端
    if [ -f "frontend/frontend.pid" ]; then
        FRONTEND_PID=$(cat frontend/frontend.pid)
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            kill $FRONTEND_PID
            echo -e "${GREEN}[前端] 已停止，PID: $FRONTEND_PID${NC}"
        fi
        rm -f frontend/frontend.pid
    fi
    
    # 强制停止相关进程
    pkill -f "node.*server.js" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true
    
    echo -e "${GREEN}✅ 本地服务已停止${NC}"
}

# 查看服务状态
show_status() {
    echo -e "${BLUE}📊 服务状态:${NC}"
    
    # 检查后端
    if pgrep -f "node.*server.js" > /dev/null; then
        echo -e "${GREEN}✅ 后端服务: 运行中${NC}"
    else
        echo -e "${RED}❌ 后端服务: 未运行${NC}"
    fi
    
    # 检查前端
    if pgrep -f "vite" > /dev/null; then
        echo -e "${GREEN}✅ 前端服务: 运行中${NC}"
    else
        echo -e "${RED}❌ 前端服务: 未运行${NC}"
    fi
    
    # 检查端口
    if netstat -tuln 2>/dev/null | grep -q ":3000 "; then
        echo -e "${GREEN}✅ 前端端口 3000: 已监听${NC}"
    else
        echo -e "${RED}❌ 前端端口 3000: 未监听${NC}"
    fi
    
    if netstat -tuln 2>/dev/null | grep -q ":3001 "; then
        echo -e "${GREEN}✅ 后端端口 3001: 已监听${NC}"
    else
        echo -e "${RED}❌ 后端端口 3001: 未监听${NC}"
    fi
}

# 查看服务日志
show_logs() {
    echo -e "${BLUE}📋 服务日志:${NC}"
    echo ""
    
    if [ "$1" = "backend" ] || [ -z "$1" ]; then
        echo -e "${YELLOW}=== 后端日志 ===${NC}"
        if [ -f "backend/backend.log" ]; then
            tail -20 backend/backend.log
        else
            echo -e "${RED}后端日志文件不存在${NC}"
        fi
        echo ""
    fi
    
    if [ "$1" = "frontend" ] || [ -z "$1" ]; then
        echo -e "${YELLOW}=== 前端日志 ===${NC}"
        if [ -f "frontend/frontend.log" ]; then
            tail -20 frontend/frontend.log
        else
            echo -e "${RED}前端日志文件不存在${NC}"
        fi
    fi
}

# 构建部署包
build_deploy() {
    echo -e "${BLUE}📦 构建部署包...${NC}"
    
    # 构建前端
    echo -e "${YELLOW}📦 构建前端...${NC}"
    cd frontend
    npm run build
    cd ..
    
    # 构建后端
    echo -e "${YELLOW}📦 构建后端...${NC}"
    cd backend
    npm install --production
    cd ..
    
    # 创建部署包
    echo -e "${YELLOW}📦 创建部署包...${NC}"
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
npx serve -s . -l 7861 &
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
EXPOSE 7861 7860

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
      - "7861:7861"
      - "7860:7860"
    environment:
      - NODE_ENV=production
    volumes:
      - ./backend/uploads:/app/backend/uploads
      - ./backend/wardrobe.db:/app/backend/wardrobe.db
    restart: unless-stopped
EOF
    
    echo -e "${GREEN}✅ 部署包已创建在 $DEPLOY_DIR 目录${NC}"
}

# 部署到CVM
deploy_cvm() {
    echo -e "${BLUE}🚀 部署到腾讯云 CVM...${NC}"
    
    SERVER_IP=${1:-$SERVER_IP}
    USERNAME=${2:-$SERVER_USER}
    KEY_FILE=${3:-""}
    
    if [ -z "$KEY_FILE" ]; then
        echo -e "${RED}❌ 请提供SSH密钥文件路径${NC}"
        echo "用法: $0 deploy-cvm [IP] [USER] [KEY_FILE]"
        exit 1
    fi
    
    if [ ! -f "$KEY_FILE" ]; then
        echo -e "${RED}❌ 密钥文件不存在: $KEY_FILE${NC}"
        exit 1
    fi
    
    # 构建部署包
    build_deploy
    
    # 上传到服务器
    echo -e "${YELLOW}📤 上传到服务器...${NC}"
    scp -i "$KEY_FILE" -r deploy/* $USERNAME@$SERVER_IP:/home/$USERNAME/wardrobe/
    
    # 在服务器上部署
    echo -e "${YELLOW}🔧 在服务器上部署...${NC}"
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
echo "🌐 访问地址: http://$SERVER_IP:7861"
EOF
    
    echo -e "${GREEN}✅ 部署完成！${NC}"
    echo -e "${CYAN}🌐 访问地址: http://$SERVER_IP:7861${NC}"
}

# 连接到服务器
connect_server() {
    echo -e "${BLUE}🚀 连接腾讯云服务器${NC}"
    echo -e "${YELLOW}服务器信息：${NC}"
    echo -e "  IP: ${GREEN}$SERVER_IP${NC}"
    echo -e "  用户名: ${GREEN}$SERVER_USER${NC}"
    echo -e "  系统: Ubuntu Server 24.04 LTS"
    echo ""
    
    # 检查 SSH 密钥
    if [ -f ~/.ssh/id_rsa ]; then
        echo -e "${GREEN}✅ 检测到 SSH 密钥，使用密钥登录${NC}"
        ssh $SERVER_USER@$SERVER_IP
    else
        echo -e "${YELLOW}🔑 未检测到 SSH 密钥，使用密码登录${NC}"
        echo -e "密码: ${GREEN}$SERVER_PASSWORD${NC}"
        echo ""
        ssh $SERVER_USER@$SERVER_IP
    fi
}

# 连接到小皮球服务器
connect_xiaopiqi() {
    echo -e "${BLUE}🚀 连接腾讯云服务器 - 小皮球${NC}"
    echo -e "${YELLOW}服务器信息：${NC}"
    echo -e "  实例ID: lhins-g1iwwlta"
    echo -e "  IP: ${GREEN}$SERVER_IP${NC}"
    echo -e "  用户名: ${GREEN}$SERVER_USER${NC}"
    echo -e "  系统: Ubuntu Server 24.04 LTS"
    echo -e "  连接方式: SSH 密码认证"
    echo ""
    
    # 使用 sshpass 进行密码认证（如果安装了）
    if command -v sshpass >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 使用 sshpass 自动登录${NC}"
        sshpass -p "$SERVER_PASSWORD" ssh $SERVER_USER@$SERVER_IP
    else
        echo -e "${YELLOW}🔑 手动输入密码登录${NC}"
        echo -e "密码: ${GREEN}$SERVER_PASSWORD${NC}"
        echo ""
        echo -e "${CYAN}提示：安装 sshpass 可以实现自动登录${NC}"
        echo "安装命令: brew install sshpass (macOS)"
        echo ""
        ssh $SERVER_USER@$SERVER_IP
    fi
}

# 清理构建文件
clean_build() {
    echo -e "${BLUE}🧹 清理构建文件...${NC}"
    
    # 停止服务
    stop_local
    
    # 删除构建文件
    rm -rf deploy/
    rm -rf frontend/dist/
    rm -rf backend/node_modules/
    rm -rf frontend/node_modules/
    rm -f backend/backend.log
    rm -f frontend/frontend.log
    rm -f backend/backend.pid
    rm -f frontend/frontend.pid
    
    echo -e "${GREEN}✅ 构建文件清理完成${NC}"
}

# 主函数
main() {
    case "${1:-help}" in
        "build")
            build_local
            start_local
            ;;
        "start")
            start_local
            ;;
        "stop")
            stop_local
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "deploy")
            build_deploy
            ;;
        "deploy-cvm")
            deploy_cvm "$2" "$3" "$4"
            ;;
        "deploy-tke")
            echo -e "${YELLOW}⚠️  TKE部署功能待实现${NC}"
            ;;
        "deploy-scf")
            echo -e "${YELLOW}⚠️  SCF部署功能待实现${NC}"
            ;;
        "deploy-cursor")
            echo -e "${YELLOW}⚠️  Cursor部署功能待实现${NC}"
            ;;
        "connect")
            connect_server
            ;;
        "connect-xiaopiqi")
            connect_xiaopiqi
            ;;
        "clean")
            clean_build
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知选项: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 