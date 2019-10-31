#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

printBanner "Installing flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/k8s-manifests/kube-flannel-rbac.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/k8s-manifests/kube-flannel-legacy.yml
exit $?
