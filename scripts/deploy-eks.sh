#!/bin/bash
set -e
TAG=${1:-latest}
REGION="eu-north-1"
ACCOUNT="015800952701"
REPO="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/pi-credit-app"

# Ensure kubectl configured (either KUBECONFIG env or use aws eks update-kubeconfig)
kubectl -n pi-credit get deploy pi-credit-app >/dev/null 2>&1 || kubectl apply -f k8s/namespace.yaml && kubectl apply -f k8s/deployment.yaml -n pi-credit && kubectl apply -f k8s/service.yaml -n pi-credit

kubectl -n pi-credit set image deployment/pi-credit-app pi-credit-app=${REPO}:${TAG}
kubectl -n pi-credit rollout status deployment/pi-credit-app --timeout=120s
echo "Deployed ${REPO}:${TAG} to EKS"
