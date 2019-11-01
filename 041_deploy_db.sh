# deploy postgres

cat - >/tmp/db-configmap.yaml <<EOB
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
  labels:
    app: db
data:
  POSTGRES_DB: db
  POSTGRES_USER: db
  POSTGRES_PASSWORD: asdfasdf
EOB

kubectl apply -f /tmp/db-configmap.yaml 

cat - >/tmp/db-volume.yaml  <<EOB
kind: PersistentVolume
apiVersion: v1
metadata:
  name: db-volume
  labels:
    type: local
    app: db
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/volums/db"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: db-volume-claim
  labels:
    app: db
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOB

kubectl apply -f /tmp/db-volume.yaml

cat - >/tmp/db-deployment.yaml <<EOB	
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  labels:
    app: db
spec:
  selector:
    matchLabels:
      app: db
  replicas: 1
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: postgres
          image: postgres:10.4
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432
          envFrom:
            - configMapRef:
                name: db-config
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: db-data
      volumes:
        - name: db-data
          persistentVolumeClaim:
            claimName: db-volume-claim
EOB

kubectl apply -f /tmp/db-deployment.yaml

cat - >/tmp/db-service.yaml <<EOB
apiVersion: v1
kind: Service
metadata:
  name: db
  labels:
    app: db
spec:
  type: NodePort
  ports:
   - port: 5432
  selector:
   app: db
EOB

kubectl apply -f /tmp/db-service.yaml 

#https://kubernetes.io/blog/2017/02/postgresql-clusters-kubernetes-statefulsets
