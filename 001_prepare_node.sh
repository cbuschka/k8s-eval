#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Configuring swap..."
ssh ${user}@${host} "
swapon -s
swapoff -a
"

printBanner "Configuring docker daemon..."
ssh ${user}@${host} "
cat > /etc/docker/daemon.json <<EOF
{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"],
  \"log-driver\": \"json-file\",
  \"log-opts\": {
    \"max-size\": \"100m\"
  },
  \"storage-driver\": \"overlay2\"
}
EOF
"

printBanner "Configuring network system settings...."
ssh ${user}@${host} "
modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
"

printBanner "Removing conflicting packages..."
ssh ${user}@${host} "
apt-get remove docker docker-engine docker.io containerd runc || true
"

printBanner "Installing precondiditions..."
ssh ${user}@${host} "
apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common
"

printBanner "Installing docker packages..."
ssh ${user}@${host} "
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo \"deb [arch=amd64] https://download.docker.com/linux/debian stretch stable\" > /etc/apt/sources.list.d/download_docker_com_linux_debian.list
apt-get -y update && apt-get install -qy docker-ce docker-ce-cli containerd.io
"

printBanner "Installing k8s packages..."
ssh ${user}@${host} "
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/apt_kubernetes_io_kubernetes-xenial.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get -y update && apt-get install -qy kubelet kubeadm kubectl
"

exit $?

