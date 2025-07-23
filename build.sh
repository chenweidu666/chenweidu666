#!/bin/bash

set -e

# 检查 Node.js 和 npm
if ! command -v node >/dev/null 2>&1; then
  echo "[错误] 未检测到 Node.js，请先安装 Node.js (https://nodejs.org/)"
  exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "[错误] 未检测到 npm，请先安装 npm (https://nodejs.org/)"
  exit 1
fi

# 安装后端依赖
cd backend
if [ ! -d "node_modules" ]; then
  echo "[后端] 安装依赖..."
  npm install
else
  echo "[后端] 已安装依赖，跳过安装。"
fi

# 启动后端
nohup npm run dev > backend.log 2>&1 &
BACKEND_PID=$!
echo "[后端] 已启动，PID: $BACKEND_PID"
cd ..

# 安装前端依赖
cd frontend
if [ ! -d "node_modules" ]; then
  echo "[前端] 安装依赖..."
  npm install
else
  echo "[前端] 已安装依赖，跳过安装。"
fi

# 启动前端
nohup npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!
echo "[前端] 已启动，PID: $FRONTEND_PID"
cd ..

# 显示访问地址
echo "\n[完成] 系统已启动："
echo "前端：http://localhost:3000"
echo "后端：http://localhost:3001"
echo "如需停止服务，请手动 kill $BACKEND_PID $FRONTEND_PID" 