#!/usr/bin/env bash
set -e

echo "🟡 Setting canary weight = 50% ..."

kubectl annotate ingress task-manager-canary \
  nginx.ingress.kubernetes.io/canary-weight="50" --overwrite

echo "✔️ Canary set to 50%"
kubectl describe ingress task-manager-canary | grep canary
