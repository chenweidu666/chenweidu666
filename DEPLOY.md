# 腾讯云部署指南

本文档介绍如何将衣服管理系统部署到腾讯云的不同服务上。

## 🚀 部署选项

### 1. 腾讯云 CVM (云服务器) - 推荐新手
- **优点**: 简单易用，完全控制
- **适用场景**: 个人项目、小团队
- **成本**: 中等

### 2. 腾讯云 TKE (容器服务) - 推荐企业
- **优点**: 高可用、自动扩缩容
- **适用场景**: 企业级应用、高并发
- **成本**: 较高

### 3. 腾讯云 SCF (云函数) - 推荐轻量应用
- **优点**: 按需付费、自动扩缩容
- **适用场景**: 轻量级应用、API服务
- **成本**: 低

## 📋 前置准备

### 1. 腾讯云账号和密钥
```bash
# 设置腾讯云密钥
export TENCENT_SECRET_ID=你的密钥ID
export TENCENT_SECRET_KEY=你的密钥Key
```

### 2. 安装必要工具
```bash
# 安装 Docker (CVM 和 TKE 需要)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装 kubectl (TKE 需要)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 安装腾讯云 CLI (SCF 需要)
pip install tencentcloud-sdk-python
```

## 🖥️ 方案一：腾讯云 CVM 部署

### 1. 购买 CVM 实例
- 操作系统：Ubuntu 20.04 LTS
- 配置：2核4GB 起步
- 带宽：5Mbps 起步

### 2. 配置安全组
开放以下端口：
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 3000 (前端)
- 3001 (后端)

### 3. 部署应用
```bash
# 本地执行部署
./deploy-cvm.sh <服务器IP> <用户名> <密钥文件路径>

# 示例
./deploy-cvm.sh 123.456.789.123 ubuntu ~/.ssh/tencent.pem
```

### 4. 配置域名和 HTTPS
```bash
# 在服务器上安装 Nginx
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx

# 配置 Nginx
sudo nano /etc/nginx/sites-available/wardrobe
```

Nginx 配置示例：
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /api {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# 启用站点
sudo ln -s /etc/nginx/sites-available/wardrobe /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 申请 SSL 证书
sudo certbot --nginx -d your-domain.com
```

## 🐳 方案二：腾讯云 TKE 部署

### 1. 创建 TKE 集群
- 集群类型：托管集群
- 节点配置：2核4GB 起步
- 节点数量：2个起步

### 2. 配置容器镜像服务
```bash
# 登录腾讯云容器镜像服务
docker login ccr.ccs.tencentyun.com
```

### 3. 部署应用
```bash
# 部署到 TKE
./deploy-tke.sh <集群ID> <命名空间> <镜像仓库地址> <镜像标签>

# 示例
./deploy-tke.sh cls-xxxxx wardrobe ccr.ccs.tencentyun.com/your-registry/wardrobe v1.0.0
```

### 4. 配置负载均衡
```bash
# 查看服务状态
kubectl get service wardrobe-service -n wardrobe

# 配置域名解析到负载均衡器 IP
```

## ⚡ 方案三：腾讯云 SCF 部署

### 1. 创建云函数
- 运行环境：Node.js 18.13
- 内存：512MB
- 超时时间：30秒

### 2. 部署应用
```bash
# 部署到云函数
./deploy-scf.sh <函数名称> <函数版本>

# 示例
./deploy-scf.sh wardrobe-api v1.0.0
```

### 3. 配置 API 网关
- 创建 API 网关服务
- 配置路由规则
- 绑定云函数

## 🔧 环境变量配置

### 生产环境配置
```bash
# 数据库配置
export DB_PATH=/app/backend/wardrobe.db

# 文件上传配置
export UPLOAD_PATH=/app/backend/uploads

# 跨域配置
export CORS_ORIGIN=https://your-domain.com

# 日志配置
export LOG_LEVEL=info
```

## 📊 监控和日志

### 1. 腾讯云监控
- 配置云监控告警
- 设置 CPU、内存、磁盘使用率告警
- 配置 API 调用量监控

### 2. 日志收集
```bash
# 查看应用日志
docker logs wardrobe-app

# 查看 Kubernetes 日志
kubectl logs -f deployment/wardrobe-app -n wardrobe

# 查看云函数日志
tcb fn logs --name wardrobe-api
```

## 🔒 安全配置

### 1. 网络安全
- 配置安全组规则
- 使用 VPC 网络隔离
- 配置 WAF 防护

### 2. 数据安全
- 数据库定期备份
- 文件存储加密
- API 接口鉴权

### 3. 访问控制
- 配置 IAM 权限
- 使用密钥管理服务
- 定期轮换密钥

## 💰 成本优化

### 1. CVM 优化
- 选择合适的实例规格
- 使用预留实例
- 配置自动关机

### 2. TKE 优化
- 配置 HPA 自动扩缩容
- 使用 Spot 实例
- 优化资源请求

### 3. SCF 优化
- 合理设置内存配置
- 优化冷启动时间
- 使用预置并发

## 🚨 故障排查

### 常见问题
1. **服务无法访问**
   - 检查安全组配置
   - 验证端口是否开放
   - 查看服务状态

2. **数据库连接失败**
   - 检查数据库文件权限
   - 验证存储空间
   - 查看错误日志

3. **文件上传失败**
   - 检查存储空间
   - 验证文件权限
   - 查看上传日志

### 联系支持
- 腾讯云技术支持：4009-100-100
- 文档中心：https://cloud.tencent.com/document
- 开发者社区：https://cloud.tencent.com/developer 