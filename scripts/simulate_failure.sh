#!/usr/bin/env bash
set -e

echo "🔥 Simulating failure: deleting 1 GREEN pod..."

POD=$(kubectl get pod -l app=task-manager,version=green -o jsonpath='{.items[0].metadata.name}')

kubectl delete pod "$POD"

echo "✔️ Pod deleted. Kubernetes will auto-recreate it."
watch -n 2 kubectl get pods -l app=task-manager
