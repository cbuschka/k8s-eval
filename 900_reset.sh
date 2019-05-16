#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Resetting..."
ssh ${user}@${host} "
kubeadm reset
rm -rf /etc/kubernetes/
"

exit $?
