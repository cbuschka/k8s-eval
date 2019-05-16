#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

printBanner "Tainting master..."
kubectl taint nodes --all node-role.kubernetes.io/master-

exit $?
