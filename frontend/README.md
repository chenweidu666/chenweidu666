# 衣服管理系统 - 前端

## 技术栈
- React 18
- TypeScript
- Vite
- Tailwind CSS
- React Router DOM
- React Hook Form
- Axios
- Lucide React Icons
- React Hot Toast

## 安装依赖
```bash
npm install
```

## 开发模式运行
```bash
npm run dev
```

## 构建生产版本
```bash
npm run build
```

## 预览生产版本
```bash
npm run preview
```

## 项目结构
```
src/
├── components/     # 组件
│   └── Navbar.tsx  # 导航栏
├── pages/         # 页面
│   ├── Dashboard.tsx      # 仪表板
│   ├── ClothesList.tsx    # 衣服列表
│   ├── AddClothes.tsx     # 添加衣服
│   ├── EditClothes.tsx    # 编辑衣服
│   └── ClothesDetail.tsx  # 衣服详情
├── services/      # API 服务
│   └── api.ts     # API 接口
├── types/         # TypeScript 类型定义
│   └── index.ts   # 类型定义
├── App.tsx        # 主应用组件
├── main.tsx       # 应用入口
└── index.css      # 全局样式
```

## 功能特性
- 📱 响应式设计，支持移动端
- 🖼️ 图片上传和预览
- 🔍 搜索和分类筛选
- 📊 数据统计展示
- ✨ 现代化 UI 界面
- 🎯 表单验证
- 🔔 消息提示 