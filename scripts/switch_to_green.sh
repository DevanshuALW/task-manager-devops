#!/usr/bin/env bash
set -e

echo "🟢 Switching traffic to GREEN..."

kubectl patch svc task-manager-svc -p '
{
  "spec": {
    "selector": {
      "app": "task-manager",
      "version": "green"
    }
  }
}'

echo "✔️ Traffic switched to GREEN"
kubectl get svc task-manager-svc -o wide
