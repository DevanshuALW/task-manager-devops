#!/usr/bin/env bash
set -e

echo "🟡 Setting canary weight = 20% ..."

kubectl annotate ingress task-manager-canary \
  nginx.ingress.kubernetes.io/canary-weight="20" --overwrite

echo "✔️ Canary set to 20%"
kubectl describe ingress task-manager-canary | grep canary
