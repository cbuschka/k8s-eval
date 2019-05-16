#!/bin/bash

set -e

source $(dirname $0)/configrc
source $(dirname $0)/lib.include.sh

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/fafa0a6e133c73e2b95d1a0504f8066c08e4a162/deploy/mandatory.yaml
#patched from kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/fafa0a6e133c73e2b95d1a0504f8066c08e4a162/deploy/provider/baremetal/service-nodeport.yaml
cat - >/tmp/nginx-ingress-service.yml <<EOB
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  # externalTrafficPolicy: Local
  externalTrafficPolicy: Cluster
  type: LoadBalancer
  loadBalancerIP: ${host}
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
  externalIPs:
    - "${host}"
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
EOB
kubectl apply -f /tmp/nginx-ingress-service.yml

kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx

exit $?