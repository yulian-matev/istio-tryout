#!/bin/bash

######### ** FOR MASTER NODE ** #########

hostname k8s-msr-1
echo "k8s-msr-1" > /etc/hostname

export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${private_key}
export AWS_DEFAULT_REGION=${region}

apt update
apt upgrade -y

# Install Docker
apt install ca-certificates curl gnupg wget apt-transport-https -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


usermod -aG docker ubuntu


# Download and Install Minikube Binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# Verify minikube version
minikube version > ~/minikube-version.txt

# Install Kubectl tool
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# Verify Kubectl tool
kubectl version -o yaml > ~/kubectl-version.txt


minikube start --nodes 2 | tee ~/minikube-start.txt
