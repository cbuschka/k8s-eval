# k8s Cheatcheet


### show cluster info
```
kubectl cluster-info
```

### start local proxy into cluster
```
kubectl proxy
```

### get token for login
```
kubectl -n kube-system get secret | grep admin-user | awk '{print $1}'

kubectl -n kube-system describe secret admin-user-token-lgqsj
```

### list pods
```
kubectl get pods
```
