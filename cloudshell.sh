#!/bin/bash


# Task 1
gcloud container clusters get-credentials hello-demo-cluster --zone us-central1-a
kubectl scale deployment hello-server --replicas=2

# Task 2
gcloud container clusters resize hello-demo-cluster --node-pool node \
    --num-nodes 3 --zone us-central1-a

gcloud container node-pools create larger-pool \
  --cluster=hello-demo-cluster \
  --machine-type=e2-standard-2 \
  --num-nodes=1 \
  --zone=us-central1-a

# Task 3

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=node -o=name); do
  kubectl cordon "$node";
done
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=node -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node";
done
kubectl get pods -o=wide
gcloud container node-pools delete node --cluster hello-demo-cluster --zone us-central1-a

gcloud container clusters create regional-demo --region=us-central1 --num-nodes=1

# cat << EOF > pod-1.yaml
# apiVersion: v1
# kind: Pod
# metadata:
#   name: pod-1
#   labels:
#     security: demo
# spec:
#   containers:
#   - name: container-1
#     image: gcr.io/google-samples/hello-app:2.0
# EOF
kubectl apply -f pod-1.yaml

# cat << EOF > pod-2.yaml
# apiVersion: v1
# kind: Pod
# metadata:
#   name: pod-2
# spec:
#   affinity:
#     podAntiAffinity:
#       requiredDuringSchedulingIgnoredDuringExecution:
#       - labelSelector:
#           matchExpressions:
#           - key: security
#             operator: In
#             values:
#             - demo
#         topologyKey: "kubernetes.io/hostname"
#   containers:
#   - name: container-2
#     image: gcr.io/google-samples/node-hello:1.0
# EOF
kubectl apply -f pod-2.yaml

# kubectl get pod pod-1 pod-2 --output wide
# kubectl exec -it pod-1 -- sh

# Task 4
kubectl delete pod pod-2
kubectl create -f pod-3.yaml

# kubectl get pod pod-1 pod-2 --output wide
# kubectl exec -it pod-1 -- sh