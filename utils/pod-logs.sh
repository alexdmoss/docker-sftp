pod=$1
kubectl logs $(kubectl get pods | grep $pod | awk '{print $1}')

