#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

printBanner "Initializing k8s master..."
ssh ${user}@${host} "
if [ -f '/etc/kubernetes/admin.conf' ]; then
  echo 'K8s already installed.'
  exit 1
fi
kubeadm init --log-file /tmp/kubeadm.log --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --service-dns-domain ${cluster_domain} --apiserver-advertise-address=${host} --apiserver-bind-port 6443 --kubernetes-version ${kubeadm_k8s_version}
# no --node-name
"

exit $?
