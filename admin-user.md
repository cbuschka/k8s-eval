### create dashboard user "admin-user"

```
cat - > admin-user.yml <<EOB
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
EOB

kubectl apply -f admin-user.yml
```

### assign roles

```
cat - > admin-user-roles.yml <<EOB
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

kubectl apply -f admin-user-roles.yml
```
