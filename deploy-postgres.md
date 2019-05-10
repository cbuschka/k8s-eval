# deploy postgres

https://severalnines.com/blog/using-kubernetes-deploy-postgresql

´´´
cat - >example-postgres-configmap.yaml <<EOB
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-postgres-config
  labels:
    app: postgres
data:
  POSTGRES_DB: example
  POSTGRES_USER: example
  POSTGRES_PASSWORD: asdfasdf
EOB

kubectl create -f example-postgres-configmap.yaml 
´´´

´´´
cat - >example-postgres-storage.yaml  <<EOB
kind: PersistentVolume
apiVersion: v1
metadata:
  name: example-postgres-pv-volume
  labels:
    type: local
    app: postgres
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/data"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: example-postgres-pv-claim
  labels:
    app: postgres
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOB

kubectl create -f example-postgres-storage.yaml
´´´

### create the deployment

```
cat - >example-postgres-deployment.yaml <<EOB	
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: example-postgres
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:10.4
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432
          envFrom:
            - configMapRef:
                name: example-postgres-config
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: postgresdb
      volumes:
        - name: postgresdb
          persistentVolumeClaim:
            claimName: example-postgres-pv-claim
EOB

kubectl create -f example-postgres-deployment.yaml
```

```
cat - >example-postgres-service.yaml <<EOB
apiVersion: v1
kind: Service
metadata:
  name: example-postgres
  labels:
    app: postgres
spec:
  type: NodePort
  ports:
   - port: 5432
  selector:
   app: postgres
EOB

kubectl create -f example-postgres-service.yaml 

kubectl get svc example-postgres
```

```
# kubectl delete service postgres 
# kubectl delete deployment postgres
# kubectl delete configmap postgres-config
# kubectl delete persistentvolumeclaim postgres-pv-claim
# kubectl delete persistentvolume postgres-pv-volume
```



Read 

https://kubernetes.io/blog/2017/02/postgresql-clusters-kubernetes-statefulsets

for scaling postgres via stateful sets.
