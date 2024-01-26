#!/bin/bash

######### ** FOR MASTER NODE ** #########

hostname k8s-msr-1
echo "k8s-msr-1" > /etc/hostname

export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${private_key}
export AWS_DEFAULT_REGION=${region}

# Step 1
# https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99

apt-get update
apt-get upgrade -y

# Step 2: Disable Swap (all nodes)
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Step 3: Add Kernel Parameters (all nodes)
tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Configure the critical kernel parameters for Kubernetes
tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# reload system changes
sysctl --system


# Step 4: Install Containerd Runtime (all nodes)
apt-get install -y curl \
                   gnupg2 \
                   software-properties-common \
                   apt-transport-https \
                   ca-certificates

# Enable Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get install -y containerd.io

# Configure containerd to start using systemd as cgroup
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Restart and enable 'containerd' service
systemctl restart containerd
systemctl enable containerd


# Step 5: Add Apt Repository for Kubernetes (all nodes)
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"


# Step 6: Install Kubectl, Kubeadm, and Kubelet (all nodes)
apt-get update
apt-get install -y kubelet \
                   kubeadm \
                   kubectl
apt-mark hold kubelet kubeadm kubectl

# install aws
apt-get install -y awscli

# install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor |  tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm


# Step 7: Initialize Kubernetes Cluster with Kubeadm (master node)
kubeadm init | tee /root/kubeadm-init.txt >/dev/null 2>&1
# produces:
#         kubeadm join 10.0.1.252:6443 --token advry3.80up3qdkntl7bmo4 \
#           --discovery-token-ca-cert-hash sha256:27036884e6e0eae4ba32fc85df546096ee34af7d26e62170b2b6064fb6064a52

# save "k8s join" command to S3 bucket
tail -2 /root/kubeadm-init.txt > /tmp/join_command.sh;
aws s3 cp /tmp/join_command.sh s3://${s3buckit_name};

mkdir -p /root/.kube
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Needed for consequent kubectl
export KUBECONFIG=/root/.kube/config

kubectl get nodes     >>  ${dbg_file} 2>&1
kubectl get pods -A   >>  ${dbg_file} 2>&1
# Debug
# for iter in {1..20}
# do
#   sleep 10
#   echo $iter >> ${dbg_file}
#   date >> ${dbg_file}
#   kubectl get pods -A >> ${dbg_file} 2>&1
# done

#Step :9 Install Kubernetes Network Plugin (master node)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml > /root/calico-stat.txt 2>&1

# install nginx ingress
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm install ingress --namespace ingress \
#                      --create-namespace \
#                      --set rbac.create=true,controller.kind=DaemonSet,controller.service.type=ClusterIP,controller.hostNetwork=true \
#                      ingress-nginx/ingress-nginx > /root/ingress.txt 2>&1

# helm list -A >> /root/ingress.txt 2>&1



curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# # Install Docker
# apt install ca-certificates curl gnupg wget apt-transport-https -y
# install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# chmod a+r /etc/apt/keyrings/docker.gpg
# echo \
#   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#   tee /etc/apt/sources.list.d/docker.list > /dev/null
# apt update
# apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# usermod -aG docker ubuntu


# # Download and Install Minikube Binary
# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# install minikube-linux-amd64 /usr/local/bin/minikube

# # Verify minikube version
# minikube version > ~/minikube-version.txt

# # Install Kubectl tool
# curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
# chmod +x kubectl
# mv kubectl /usr/local/bin/

# # Verify Kubectl tool
# kubectl version -o yaml > ~/kubectl-version.txt


# minikube start --nodes 2 | tee ~/minikube-start.txt



# install nginx ingress
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm install ingress --namespace ingress \
#                      --create-namespace \
#                      --set rbac.create=true,\
#                            controller.kind=DaemonSet,\
#                            controller.service.type=ClusterIP,\
#                            controller.hostNetwork=true \
#                            ingress-nginx/ingress-nginx