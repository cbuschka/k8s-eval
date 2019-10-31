#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
echo "Exec 'kubectl proxy' and go to http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

exit $?
