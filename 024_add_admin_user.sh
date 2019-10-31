#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

printBanner "Creating admin user..."
cat - > /tmp/admin-user.yml <<EOB
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
EOB

kubectl apply -f /tmp/admin-user.yml

cat - > /tmp/admin-user-roles.yml <<EOB
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOB

kubectl apply -f /tmp/admin-user-roles.yml

printBanner "Extracting login token..."
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

exit $?
