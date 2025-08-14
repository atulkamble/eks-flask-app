#!/usr/bin/env bash
set -euo pipefail
OVERLAY=${1:-dev}
kubectl apply -k k8s/overlays/${OVERLAY}
kubectl rollout status deploy/eks-flask -n demo
kubectl get svc -n demo eks-flask-svc -o wide
