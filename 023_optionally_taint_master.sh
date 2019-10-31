#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

printBanner "Tainting master..."
kubectl taint nodes --all node-role.kubernetes.io/master-

exit $?
