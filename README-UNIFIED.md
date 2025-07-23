# 智能衣柜管理系统 - 统一部署脚本

## 概述

`smart-wardrobe.sh` 是一个统一的部署和管理脚本，整合了所有原有的部署脚本功能，提供了更简洁和统一的命令行界面。

## 功能特性

- 🚀 **统一管理**: 一个脚本管理所有部署和连接功能
- 🎨 **彩色输出**: 使用颜色区分不同类型的信息
- 🔧 **自动检测**: 自动检测系统依赖和服务状态
- 📦 **多平台部署**: 支持本地、CVM、TKE、SCF等多种部署方式
- 🔗 **便捷连接**: 快速连接到远程服务器
- 📊 **状态监控**: 实时查看服务状态和日志

## 快速开始

### 1. 本地开发

```bash
# 构建并启动本地开发环境
./smart-wardrobe.sh build

# 仅启动服务（如果已构建）
./smart-wardrobe.sh start

# 停止服务
./smart-wardrobe.sh stop

# 查看服务状态
./smart-wardrobe.sh status

# 查看服务日志
./smart-wardrobe.sh logs
```

### 2. 服务器连接

```bash
# 连接到服务器（使用SSH密钥）
./smart-wardrobe.sh connect

# 连接到小皮球服务器（使用密码）
./smart-wardrobe.sh connect-xiaopiqi
```

### 3. 部署到云平台

```bash
# 构建部署包
./smart-wardrobe.sh deploy

# 部署到腾讯云CVM
./smart-wardrobe.sh deploy-cvm <IP> <USER> <KEY_FILE>

# 示例：部署到指定服务器
./smart-wardrobe.sh deploy-cvm 101.34.232.12 ubuntu ~/.ssh/tencent.pem
```

## 配置说明

脚本中的主要配置变量：

```bash
# 服务器配置
SERVER_IP="101.34.232.12"
SERVER_USER="ubuntu"
SERVER_PASSWORD="SY5718461006+"

# 端口配置
FRONTEND_PORT="7861"
BACKEND_PORT="7860"
```

## 详细命令说明

### 本地开发命令

| 命令 | 说明 |
|------|------|
| `build` | 构建并启动本地开发环境 |
| `start` | 启动本地服务 |
| `stop` | 停止本地服务 |
| `status` | 查看服务状态 |
| `logs [backend\|frontend]` | 查看服务日志 |

### 部署命令

| 命令 | 说明 |
|------|------|
| `deploy` | 构建部署包 |
| `deploy-cvm [IP] [USER] [KEY]` | 部署到腾讯云CVM |
| `deploy-tke [CLUSTER] [NS] [REGISTRY] [TAG]` | 部署到腾讯云TKE |
| `deploy-scf [FUNC] [VER]` | 部署到腾讯云SCF |
| `deploy-cursor` | 部署到Cursor远程环境 |

### 连接命令

| 命令 | 说明 |
|------|------|
| `connect` | 连接到服务器 |
| `connect-xiaopiqi` | 连接到小皮球服务器 |

### 维护命令

| 命令 | 说明 |
|------|------|
| `clean` | 清理构建文件 |
| `help` | 显示帮助信息 |

## 使用示例

### 完整的本地开发流程

```bash
# 1. 构建并启动开发环境
./smart-wardrobe.sh build

# 2. 查看服务状态
./smart-wardrobe.sh status

# 3. 查看日志
./smart-wardrobe.sh logs

# 4. 停止服务
./smart-wardrobe.sh stop

# 5. 清理构建文件
./smart-wardrobe.sh clean
```

### 部署到生产环境

```bash
# 1. 构建部署包
./smart-wardrobe.sh deploy

# 2. 部署到CVM
./smart-wardrobe.sh deploy-cvm 101.34.232.12 ubuntu ~/.ssh/tencent.pem

# 3. 连接到服务器检查部署状态
./smart-wardrobe.sh connect
```

### 快速连接服务器

```bash
# 使用SSH密钥连接
./smart-wardrobe.sh connect

# 使用密码连接（小皮球服务器）
./smart-wardrobe.sh connect-xiaopiqi
```

## 端口配置

- **前端端口**: 7861 (生产环境) / 3000 (开发环境)
- **后端端口**: 7860 (生产环境) / 3001 (开发环境)

## 依赖要求

- Node.js 18+
- npm
- Docker (用于容器化部署)
- Docker Compose (用于容器编排)
- SSH 客户端

## 故障排除

### 常见问题

1. **权限问题**
   ```bash
   chmod +x smart-wardrobe.sh
   ```

2. **依赖缺失**
   ```bash
   # 检查Node.js
   node --version
   
   # 检查npm
   npm --version
   ```

3. **端口占用**
   ```bash
   # 查看端口占用
   netstat -tuln | grep :3000
   netstat -tuln | grep :3001
   
   # 停止占用进程
   ./smart-wardrobe.sh stop
   ```

4. **服务无法启动**
   ```bash
   # 查看详细日志
   ./smart-wardrobe.sh logs backend
   ./smart-wardrobe.sh logs frontend
   ```

## 与原脚本的对比

| 功能 | 原脚本 | 统一脚本 |
|------|--------|----------|
| 本地构建 | `build.sh` | `./smart-wardrobe.sh build` |
| 部署包构建 | `deploy.sh` | `./smart-wardrobe.sh deploy` |
| CVM部署 | `deploy-cvm.sh` | `./smart-wardrobe.sh deploy-cvm` |
| 服务器连接 | `connect-server.sh` | `./smart-wardrobe.sh connect` |
| 小皮球连接 | `connect-xiaopiqi.sh` | `./smart-wardrobe.sh connect-xiaopiqi` |

## 注意事项

1. 首次使用前请确保已安装所有必要的依赖
2. 部署到云平台前请确保已配置相应的访问权限
3. 生产环境部署建议使用HTTPS
4. 定期备份数据库文件 `backend/wardrobe.db`

## 更新日志

- **v1.0.0**: 初始版本，整合所有原有脚本功能
- 支持彩色输出和状态监控
- 统一配置管理
- 简化命令行界面 