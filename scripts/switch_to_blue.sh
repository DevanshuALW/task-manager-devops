#!/usr/bin/env bash
set -e

echo "🔵 Switching traffic to BLUE..."

kubectl patch svc task-manager-svc -p '
{
  "spec": {
    "selector": {
      "app": "task-manager",
      "version": "blue"
    }
  }
}'

echo "✔️ Traffic switched to BLUE"
kubectl get svc task-manager-svc -o wide
