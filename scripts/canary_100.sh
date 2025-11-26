#!/usr/bin/env bash
set -e

echo "🟢 Setting canary weight = 100% (full rollout to GREEN)..."

kubectl annotate ingress task-manager-canary \
  nginx.ingress.kubernetes.io/canary-weight="100" --overwrite

echo "✔️ Full traffic now GREEN"
kubectl describe ingress task-manager-canary | grep canary
