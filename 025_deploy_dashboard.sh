#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

curl -o /tmp/kubernetes-dashboard.yaml https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
#perl -i -pe 's#          - --auto-generate-certificates#          - --auto-generate-certificates\n          - --token-ttl=600m#g' /tmp/kubernetes-dashboard.yaml
kubectl apply -f /tmp/kubernetes-dashboard.yaml

echo "Exec 'kubectl proxy' and go to http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

exit $?