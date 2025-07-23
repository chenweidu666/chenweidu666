# 衣服管理系统

本项目为前后端分离的衣服管理系统。

- 前端：React + Vite + TypeScript + Tailwind CSS
- 后端：Node.js + Express + SQLite

## 功能特性

- 📱 响应式设计，支持移动端
- 🖼️ 图片上传和管理
- 🔍 搜索和分类筛选
- 📊 数据统计和可视化
- ✨ 现代化 UI 界面

## 快速开始

### 一键启动（推荐）

```bash
# 确保已安装 Node.js 和 npm
./build.sh
```

启动后访问：
- 前端：http://localhost:3000
- 后端：http://localhost:3001

### 手动启动

#### 后端
```bash
cd backend
npm install
npm run dev
```

#### 前端
```bash
cd frontend
npm install
npm run dev
```

## 🚀 部署到腾讯云

### 部署选项

1. **腾讯云 CVM (云服务器)** - 推荐新手
   ```bash
   ./deploy-cvm.sh <服务器IP> <用户名> <密钥文件路径>
   ```

2. **腾讯云 TKE (容器服务)** - 推荐企业
   ```bash
   ./deploy-tke.sh <集群ID> <命名空间> <镜像仓库地址> <镜像标签>
   ```

3. **腾讯云 SCF (云函数)** - 推荐轻量应用
   ```bash
   ./deploy-scf.sh <函数名称> <函数版本>
   ```

详细部署指南请查看 [DEPLOY.md](./DEPLOY.md)

## 目录结构
- frontend/  前端项目
- backend/   后端项目
- build.sh   一键启动脚本
- deploy.sh  部署脚本
- DEPLOY.md  部署文档

## API 接口

### 衣服管理
- `GET /api/clothes` - 获取所有衣服
- `GET /api/clothes/:id` - 获取单个衣服
- `POST /api/clothes` - 添加衣服
- `PUT /api/clothes/:id` - 更新衣服
- `DELETE /api/clothes/:id` - 删除衣服

### 分类查询
- `GET /api/clothes/category/:category` - 按分类获取衣服

### 搜索
- `GET /api/clothes/search/:query` - 搜索衣服

### 统计
- `GET /api/stats` - 获取统计信息

## 技术栈

### 前端
- React 18
- TypeScript
- Vite
- Tailwind CSS
- React Router
- React Hook Form
- Axios
- Lucide React Icons
- React Hot Toast

### 后端
- Node.js
- Express.js
- SQLite3
- Multer (文件上传)
- CORS
- UUID

## 数据库
使用 SQLite 数据库，数据库文件为 `backend/wardrobe.db`，会在首次运行时自动创建。

## 文件上传
图片文件会保存在 `backend/uploads/` 目录下。
