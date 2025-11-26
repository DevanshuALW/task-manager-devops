#!/usr/bin/env bash
set -e

echo "🧹 Cleaning up old BLUE ReplicaSets..."

kubectl get rs -l app=task-manager,version=blue

OLD_RS=$(kubectl get rs -l app=task-manager,version=blue \
  --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[:-1].metadata.name}')

for rs in $OLD_RS; do
  echo "Deleting RS $rs ..."
  kubectl delete rs $rs
done

echo "✔️ Cleanup complete"
