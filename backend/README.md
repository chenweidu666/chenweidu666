# 衣服管理系统 - 后端

## 技术栈
- Node.js
- Express.js
- SQLite3
- Multer (文件上传)
- CORS

## 安装依赖
```bash
npm install
```

## 开发模式运行
```bash
npm run dev
```

## 生产模式运行
```bash
npm start
```

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

## 数据库
使用 SQLite 数据库，数据库文件为 `wardrobe.db`，会在首次运行时自动创建。

## 文件上传
图片文件会保存在 `uploads/` 目录下。 