#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Resetting..."
ssh ${user}@${host} "
echo 'echo Resetting k8s cluster...'
kubeadm reset
echo 'Cleaning firewall rules...'
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
rm -rf /etc/kubernetes/
echo 'Done.'
"

exit $?
