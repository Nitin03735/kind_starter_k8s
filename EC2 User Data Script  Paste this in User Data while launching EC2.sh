#!/bin/bash
set -e

# Log everything
exec > /var/log/user-data.log 2>&1

echo "===== Updating system ====="
apt update -y

echo "===== Installing Docker ====="
apt install -y docker.io curl apt-transport-https ca-certificates
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

echo "===== Installing kubectl ====="
curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "===== Installing KIND ====="
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind
mv kind /usr/local/bin/kind

echo "===== Creating KIND config ====="
cat <<EOF > /home/ubuntu/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
EOF

chown ubuntu:ubuntu /home/ubuntu/kind-config.yaml

echo "===== Creating KIND cluster ====="
sudo -u ubuntu kind create cluster --name web-cluster --config /home/ubuntu/kind-config.yaml

echo "===== Waiting for cluster ====="
sleep 30

echo "===== Deploying NGINX ====="
cat <<EOF > /home/ubuntu/nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

chown ubuntu:ubuntu /home/ubuntu/nginx.yaml

echo "===== Applying Kubernetes manifests ====="
sudo -u ubuntu kubectl apply -f /home/ubuntu/nginx.yaml

echo "===== Setup Complete ====="
