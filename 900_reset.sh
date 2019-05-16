#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Resetting..."
ssh ${user}@${host} "
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
rm -rf /etc/kubernetes/
"

exit $?
