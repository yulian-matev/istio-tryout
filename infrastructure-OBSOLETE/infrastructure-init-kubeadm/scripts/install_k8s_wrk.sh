#!/bin/bash

######### ** FOR WORKER NODE ** #########

hostname k8s-wrk-${worker_number}
echo "k8s-wrk-${worker_number}" > /etc/hostname

export AWS_ACCESS_KEY_ID=${access_key}
export AWS_SECRET_ACCESS_KEY=${private_key}
export AWS_DEFAULT_REGION=${region}

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

# Restart and enable the containerd service
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

mkdir -p /root/.kube
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# install aws
apt-get install -y awscli


# Needed for consequent kubectl
export KUBECONFIG=/root/.kube/config


# Wait for the 'join_command.sh' (from S3 storage) become available. Max wait time 250s = 5*50
for iter in {1..50}
do
  sleep 5
  aws s3api head-object --bucket ${s3buckit_name} --key join_command.sh  >> /root/wait_s3.txt 2>&1 \
    && break
done


# join to k8s cluster
aws s3 cp s3://${s3buckit_name}/join_command.sh /tmp/.
chmod +x /tmp/join_command.sh
bash /tmp/join_command.sh




# CHEKING S3 file exists
#
# ubuntu@k8s-wrk-1:~$ aws s3api head-object --bucket k8s-rzef7bufj --key join_command.sh
# {
#     "AcceptRanges": "bytes",
#     "LastModified": "Tue, 23 Jan 2024 12:40:36 GMT",
#     "ContentLength": 168,
#     "ETag": "\"269bdd4a632003b6a4b2adff6b3d13af\"",
#     "ContentType": "text/x-sh",
#     "ServerSideEncryption": "AES256",
#     "Metadata": {}
# }
#
#
#aws s3api head-object --bucket k8s-rzef7bufj --key join_command.sh  > /dev/null 2>&1 || not_exist=true
