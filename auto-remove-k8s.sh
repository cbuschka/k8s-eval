#!/bin/bash

function printBanner() {
  echo "=================================================="
  echo "== $@"
  echo "=================================================="
}

# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

user=root
host=192.168.122.173

printBanner "Removing k8s..."
ssh ${user}@${host} "
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
"
