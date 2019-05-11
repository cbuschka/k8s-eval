#!/bin/bash

set -e

steps="install initk8s createAdminUser deployDashboard installIngressController deployHello"
startStep=${1:-install}

function printBanner() {
  echo "=================================================="
  echo "== $@"
  echo "=================================================="
}

# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

user=root
host=192.168.122.173

function install() {
printBanner "Configuring swap..."
ssh ${user}@${host} "
swapon -s
swapoff -a
"

printBanner "Configuring docker daemon..."
ssh ${user}@${host} "
cat > /etc/docker/daemon.json <<EOF
{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"],
  \"log-driver\": \"json-file\",
  \"log-opts\": {
    \"max-size\": \"100m\"
  },
  \"storage-driver\": \"overlay2\"
}
EOF
"

printBanner "Configuring network system settings...."
ssh ${user}@${host} "
modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
"

printBanner "Removing conflicting packages..."
ssh ${user}@${host} "
apt-get remove docker docker-engine docker.io containerd runc
"

printBanner "Installing precondiditions..."
ssh ${user}@${host} "
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
"

printBanner "Installing docker packages..."
ssh ${user}@${host} "
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo \"deb [arch=amd64] https://download.docker.com/linux/debian stretch stable\" > /etc/apt/sources.list.d/docker.list
apt-get -y update && apt-get install -qy docker-ce docker-ce-cli containerd.io
"

printBanner "Installing k8s packages..."
ssh ${user}@${host} "
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get -y update && apt-get install -y kubelet kubectl kubeadm kubernetes-cni
"
}

function initk8s() {
printBanner "Initializing k8s..."
ssh ${user}@${host} "
if [ -f '/etc/kubernetes/admin.conf' ]; then
  echo 'K8s already installed.'
  exit 1
fi
kubeadm init --log-file /tmp/kubeadm.log --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --service-dns-domain cluster.local --apiserver-advertise-address=${host} --apiserver-bind-port 6443 --kubernetes-version stable-1.14
# no --node-name
"

printBanner "Fetching kube config..."
mkdir -p ~/.kube/
scp root@ws0:/etc/kubernetes/admin.conf $HOME/.kube/config

printBanner "Installing flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

printBanner "Tainting master..."
kubectl taint nodes --all node-role.kubernetes.io/master-
}

function installIngressController() {
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
}

function createAdminUser() {
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
}

function deployDashboard() {
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
echo "Exec 'kubectl proxy' and go to http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
}

function deployHello() {
cat - > /tmp/hello-deployment.yml <<EOB
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deployment
  labels:
    app: hello
spec:
  replicas: 1
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
        image: gcr.io/hello-minikube-zero-install/hello-node
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
  - host: hello.ws0
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
}

#
# main loop
#
startStepSeen=
for step in $steps; do
  if [[ "$step" == "$startStep" ]]; then
    startStepSeen="yes"
  fi

  if [[ "x$startStepSeen" == "xyes" ]]; then
    $step
  fi
done

printBanner "ok for now"
exit 0

