#!/bin/bash

set -e

echo "🚀 部署到腾讯云 TKE..."

# 检查参数
if [ $# -lt 4 ]; then
    echo "用法: $0 <集群ID> <命名空间> <镜像仓库地址> <镜像标签>"
    echo "示例: $0 cls-xxxxx wardrobe ccr.ccs.tencentyun.com/your-registry/wardrobe v1.0.0"
    exit 1
fi

CLUSTER_ID=$1
NAMESPACE=$2
REGISTRY=$3
TAG=$4

# 构建部署包
echo "📦 构建部署包..."
./deploy.sh

# 构建 Docker 镜像
echo "🐳 构建 Docker 镜像..."
cd deploy
docker build -t $REGISTRY:$TAG .

# 推送镜像到腾讯云容器镜像服务
echo "📤 推送镜像..."
docker push $REGISTRY:$TAG
cd ..

# 创建 Kubernetes 部署文件
cat > deploy/k8s-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wardrobe-app
  namespace: $NAMESPACE
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wardrobe-app
  template:
    metadata:
      labels:
        app: wardrobe-app
    spec:
      containers:
      - name: wardrobe-app
        image: $REGISTRY:$TAG
        ports:
        - containerPort: 3000
        - containerPort: 3001
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: uploads-volume
          mountPath: /app/backend/uploads
        - name: db-volume
          mountPath: /app/backend/wardrobe.db
          subPath: wardrobe.db
      volumes:
      - name: uploads-volume
        persistentVolumeClaim:
          claimName: wardrobe-uploads-pvc
      - name: db-volume
        persistentVolumeClaim:
          claimName: wardrobe-db-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: wardrobe-service
  namespace: $NAMESPACE
spec:
  selector:
    app: wardrobe-app
  ports:
  - name: frontend
    port: 3000
    targetPort: 3000
  - name: backend
    port: 3001
    targetPort: 3001
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wardrobe-uploads-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wardrobe-db-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF

# 使用 kubectl 部署
echo "🔧 部署到 Kubernetes..."
kubectl apply -f deploy/k8s-deployment.yaml

# 等待部署完成
echo "⏳ 等待部署完成..."
kubectl rollout status deployment/wardrobe-app -n $NAMESPACE

# 获取服务地址
echo "🌐 获取服务地址..."
kubectl get service wardrobe-service -n $NAMESPACE

echo "✅ 部署完成！"
echo "📋 查看服务状态: kubectl get pods -n $NAMESPACE"
echo "📋 查看服务日志: kubectl logs -f deployment/wardrobe-app -n $NAMESPACE" 