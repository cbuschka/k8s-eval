#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Initializing k8s..."
ssh ${user}@${host} "
if [ -f '/etc/kubernetes/admin.conf' ]; then
  echo 'K8s already installed.'
  exit 1
fi
kubeadm init --log-file /tmp/kubeadm.log --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --service-dns-domain ${cluster_domain} --apiserver-advertise-address=${host} --apiserver-bind-port 6443 --kubernetes-version stable-1.14
# no --node-name
"

exit $?
