#!/bin/bash

set -e

echo "🚀 部署到腾讯云 SCF..."

# 检查参数
if [ $# -lt 2 ]; then
    echo "用法: $0 <函数名称> <函数版本>"
    echo "示例: $0 wardrobe-api v1.0.0"
    exit 1
fi

FUNCTION_NAME=$1
VERSION=$2

# 构建后端
echo "📦 构建后端..."
cd backend
npm install --production
cd ..

# 创建云函数部署包
echo "📦 创建云函数部署包..."
SCF_DIR="scf-deploy"
rm -rf $SCF_DIR
mkdir -p $SCF_DIR

# 复制后端文件
cp -r backend/* $SCF_DIR/
rm -rf $SCF_DIR/node_modules

# 创建云函数入口文件
cat > $SCF_DIR/index.js << 'EOF'
const express = require('express');
const serverless = require('serverless-http');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');

const app = express();

// 中间件
app.use(cors());
app.use(express.json());

// 云函数环境下的文件存储
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// 数据库初始化
const db = new sqlite3.Database('/tmp/wardrobe.db', (err) => {
  if (err) {
    console.error('数据库连接失败:', err.message);
  } else {
    console.log('数据库连接成功');
    initDatabase();
  }
});

function initDatabase() {
  const createTableSQL = `
    CREATE TABLE IF NOT EXISTS clothes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      color TEXT,
      size TEXT,
      season TEXT,
      image_url TEXT,
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `;
  
  db.run(createTableSQL, (err) => {
    if (err) {
      console.error('创建表失败:', err.message);
    } else {
      console.log('数据库表初始化成功');
    }
  });
}

// API路由
app.get('/api/clothes', (req, res) => {
  const sql = 'SELECT * FROM clothes ORDER BY created_at DESC';
  db.all(sql, [], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(rows);
  });
});

app.get('/api/stats', (req, res) => {
  const sql = `
    SELECT 
      COUNT(*) as total,
      COUNT(CASE WHEN category = '上衣' THEN 1 END) as tops,
      COUNT(CASE WHEN category = '裤子' THEN 1 END) as pants,
      COUNT(CASE WHEN category = '裙子' THEN 1 END) as dresses,
      COUNT(CASE WHEN category = '外套' THEN 1 END) as outerwear,
      COUNT(CASE WHEN category = '鞋子' THEN 1 END) as shoes,
      COUNT(CASE WHEN category = '配饰' THEN 1 END) as accessories
    FROM clothes
  `;
  
  db.get(sql, [], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(row);
  });
});

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 导出云函数处理器
exports.main_handler = serverless(app);
EOF

# 创建云函数配置文件
cat > $SCF_DIR/template.yaml << EOF
Resources:
  ${FUNCTION_NAME}:
    Type: TencentCloud::Serverless::Function
    Properties:
      CodeUri: .
      Handler: index.main_handler
      Runtime: Nodejs18.13
      Timeout: 30
      MemorySize: 512
      Environment:
        Variables:
          NODE_ENV: production
      Events:
        ApiEvent:
          Type: Api
          Properties:
            Path: /
            Method: ANY
        ApiEventWithPath:
          Type: Api
          Properties:
            Path: /{proxy+}
            Method: ANY
EOF

# 安装 serverless-http 依赖
cd $SCF_DIR
npm install serverless-http

# 使用腾讯云 CLI 部署
echo "🔧 部署到云函数..."
if command -v tcb &> /dev/null; then
    # 使用腾讯云 CLI
    tcb fn deploy --name $FUNCTION_NAME --code .
elif command -v serverless &> /dev/null; then
    # 使用 Serverless Framework
    serverless deploy
else
    echo "❌ 请安装腾讯云 CLI 或 Serverless Framework"
    echo "腾讯云 CLI: https://cloud.tencent.com/document/product/440/34011"
    echo "Serverless Framework: npm install -g serverless"
    exit 1
fi

cd ..

echo "✅ 云函数部署完成！"
echo "📋 函数名称: $FUNCTION_NAME"
echo "📋 版本: $VERSION"
echo "🌐 API 网关地址: https://your-api-gateway-url" 