#!/usr/bin/env bash
set -euo pipefail
REGION=${1:-us-east-1}
CLUSTER=${2:-eks-flask-app-cluster}
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
kubectl get nodes -o wide
