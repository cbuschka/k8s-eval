#!/bin/bash

set -e

source $(dirname $0)/config.d/cluster
source $(dirname $0)/config.d/master
source $(dirname $0)/lib.include.sh

cat - > /tmp/hello-deployment.yml <<EOB
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
  labels:
    app: hello
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
      - name: hello
        image: cbuschka/myhello:1.0
        ports:
        - containerPort: 8080
EOB
kubectl apply -f /tmp/hello-deployment.yml

#kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
#https://kubernetes.io/docs/concepts/services-networking/ingress/
# https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md
cat - > /tmp/hello-service.yaml <<EOB
apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  selector:
    app: hello
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  type: NodePort
EOB
kubectl apply -f /tmp/hello-service.yaml

cat - >/tmp/hello-ingress.yaml <<EOB
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/http2-push-preload: "true"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Request-Id: $req_id";
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/limit-connections: 5
    nginx.ingress.kubernetes.io/limit-rps: 20
    nginx.ingress.kubernetes.io/limit-rpm: 120
    nginx.ingress.kubernetes.io/from-to-www-redirect: "false"
    nginx.ingress.kubernetes.io/connection-proxy-header: "keep-alive"
    nginx.ingress.kubernetes.io/enable-access-log: "false"
    nginx.ingress.kubernetes.io/enable-rewrite-log: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    nginx.ingress.kubernetes.io/satisfy: "any"
spec:
  rules:
  - host: hello.${cluster_domain}
    http:
      paths:
      - path: /
        backend:
          serviceName: hello-service
          servicePort: 8080
      - path: /hello
        backend:
          serviceName: hello-service
          servicePort: 8080
EOB
kubectl apply -f /tmp/hello-ingress.yaml

exit $?
