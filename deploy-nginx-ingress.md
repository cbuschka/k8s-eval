NOT WORKING!!!

https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml

kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch

now ingress controller runs, install ingress for service
https://kubernetes.io/docs/concepts/services-networking/ingress/
