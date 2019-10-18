# notes from my k8s eval session

## ingredients
- bash, ssh
- kubeadm
- kvm
- NO minikube
- hello from cbuschka/myhello
- nginx ingress controller (no ssl)
- based on https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

## prerequesites
- vm, named ws0
- alias in /etc/hosts for ws0 called hello.ws0
- debian stretch
- ip 192.168.122.173
- 4g ram

## usage

```
./install-k8s.sh install
```

targets:
* install
* initk8s
* createAdminUser
* deployDashboard
* installIngressController
* deployHello

## helpful
[cheatsheet](./cheatsheet.md)

## license
MIT
