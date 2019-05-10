### access dashboard

```
kubectl proxy
```

[Dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default)

### extract dashboard token

of user created via [Admin user creation](admin-user.md)

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```
