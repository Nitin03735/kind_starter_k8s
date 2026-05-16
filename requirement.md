### This Installation process should be done on Linux Based EC2 Server
> I'm using t2.micro 2 coore CPU and 2 GB RAM for installation basic K8s.

## Update system
  - sudo apt install update -y && apt install upgrade -y
    
## Installation of Docker
  - sudo apt install docker.io -y

  - chnage group docker to ubuntu
      - usermod -aG docker ubuntu
      - newgrp docker
    
## Installation of KIND (K8s in Docker)
  - Download kind executable file
      - sudo [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
  - Make Kind file executable
      - sudo chmod +x kind
  - Move kind file to /usr/local/lib/
      - sudo mv ./kind /usr/local/lib/
  - install kind
      - sudo apt install kind -y
  - Check status kind
      - sudo kind --version

## Installation of Kubectl
✅ Step 2: Download kubectl v1.35
    👉 For x86_64
    - curl -LO https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl
    👉 For ARM64
    - curl -LO https://dl.k8s.io/release/v1.35.0/bin/linux/arm64/kubectl
✅ Step 3: Install
    - chmod +x kubectl
    - sudo mv kubectl /usr/local/bin/
✅ Step 4: Verify
    - kubectl version --client
     > Expected:
      > Client Version: v1.35.0
    

