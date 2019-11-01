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
- 3 vms, 192.168.0.181/182/183, 4g ram per node
- debian stretch

## usage

### prepare your client machine (still fedora only)
```
./001_prepare_client.sh
```

### prepare a node for k8s installation, master and workers
This needs a config file below config.d/.
```
002_prepare_node.sh <config name>
```

### install a k8s master via kubeadm
This needs a config file named master below config.d/.
```
010_install_master.sh
```

### fetch the config from the master for access
```
021_fetch_kube_config.sh
```

then run
```
kubectl proxy
```

### install network on master
```
022_install_flannel.sh
```

### if you want to run jobs on your master (for stability reasons dont do it)
```
023_optionally_taint_master.sh
```

### add an k8s admin user ("rbac") for access
```
024_add_admin_user.sh
```

### deploy the dashboard
```
025_deploy_dashboard.sh
```

[dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/secret?namespace=default)

### deploy an ingress controller
```
031_install_ingress_controller.sh
```

### deploy an stateless hello world app
```
040_deploy_app.sh
```

### deploy an stateful app, db with persistent volume
```
041_deploy_db.sh
```

### reset a noe
Node config below config.d/ required.
```
900_reset.sh <config file>
```

## helpful
[cheatsheet](./cheatsheet.md)

## license
MIT
