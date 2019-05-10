install docker

apt-get update
apt-get install -y apt-transport-https curl 

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl

kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join --token 354502.d6a9a425d5fa8f2e 192.168.0.9:6443 --discovery-token-ca-cert-hash sha256:ad7c5e8a0c909ed36a87452e65fa44b1c2a9729cef7285eb551e2f126a1d6a54

kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

kubectl get pods --all-namespaces

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl create namespace sock-shop

kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"

kubectl -n sock-shop get svc front-end


install nginx ingress


cleaup
 kubeadm reset

tutorial: https://www.mirantis.com/blog/how-install-kubernetes-kubeadm/
