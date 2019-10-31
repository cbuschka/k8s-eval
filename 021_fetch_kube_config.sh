#!/bin/bash

set -e

source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

printBanner "Fetching kube config..."
mkdir -p ~/.kube/
scp ${user}@${host}:/etc/kubernetes/admin.conf $HOME/.kube/config

kubectl cluster-info

exit $?
