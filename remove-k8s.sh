#!/bin/bash

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Removing k8s..."
ssh ${user}@${host} "
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
"
