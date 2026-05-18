## ✅ Step 1: Install prerequisites (EC2 Ubuntu)
# CMD /bash
sudo apt update
sudo apt install -y docker.io curl
sudo systemctl enable docker
sudo systemctl start docker
Install kubectl
curl -LO https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
Install KIND
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/

## ✅ Step 2: Create KIND config (port mapping)

Create file:

vi kind-config.yaml

Paste:

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080   # NodePort inside cluster
    hostPort: 8080         # EC2 public port
    protocol: TCP

## ✅ Step 3: Create cluster
# CMD /bash
kind create cluster --name nitin-cluster --config kind-config.yaml

Verify:

kubectl get nodes
## ✅ Step 4: Deploy NGINX Pod
# CMD /bash
kubectl run nginx --image=nginx --port=80

Verify:

kubectl get pods -o wide
## ✅ Step 5: Expose via NodePort
# CMD /bash
kubectl expose pod nginx \
  --type=NodePort \
  --port=80 \
  --target-port=80 \
  --name=my-nginx-svc
## ✅ Step 6: Force NodePort to 30080

Edit service:

# CMD /bash 
kubectl edit svc my-nginx-svc

Update: yml file 

ports:
- port: 80
  targetPort: 80
  nodePort: 30080
## ✅ Step 7: Open AWS Security Group

Go to EC2 → Security Group → Inbound Rules

Add:

Type	Port	Source
Custom TCP	8080	0.0.0.0/0

## ✅ Step 8: Test from EC2
curl localhost:8080

👉 Should return NGINX HTML

## ✅ Step 9: Access from your local browser
http://<EC2-PUBLIC-IP>:8080

🎉 You should see NGINX welcome page