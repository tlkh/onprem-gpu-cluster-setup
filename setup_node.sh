#!/bin/sh

echo -e "Per-node setup script for on-prem Kubernetes Cluster"
echo -e "Intended for Ubuntu 16.04.x or Ubuntu 18.04.x"

echo -e "Set non-interactive frontend"
echo -e "Script will run without any prompts"
export DEBIAN_FRONTEND=noninteractive

echo -e "\nInstalling Docker CE\n"

apt-get update
apt-get remove docker docker-engine docker.io containerd runc -y
apt-get install -y \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    software-properties-common
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce

echo -e "\nInstalling NVIDIA drivers and CUDA\n"

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb

dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub

apt-get update
apt-get install cuda -y

echo -e "\nInstalling NVIDIA container runtime\n"

distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list

apt-get update
apt-get install -y nvidia-container-toolkit

echo -e "\nInstalling Tools and Telemetry Stack\n"

curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list
apt-get update
apt-get install -y telegraf htop gparted ntp openssh-server nfs-common nfs-kernel-server

systemctl enable ntp
systemctl enable ssh
systemctl unmask influxdb.service
systemctl start influxdb
systemctl enable telegraf

apt update && apt autoremove -y
apt dist-upgrade -y && apt upgrade -y && apt autoremove -y

echo -e "\nDisable swap! This is a requirement for Kubernetes\n"

swapoff -a 
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo -e "\nInstalling Kubernetes components\n"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo -e "\nRestart\n"

reboot
