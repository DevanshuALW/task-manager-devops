#!/usr/bin/env bash
set -e

echo "📌 Pods:"
kubectl get pods -l app=task-manager -o wide

echo "📌 Service:"
kubectl get svc task-manager-svc

echo "📌 Ingress:"
kubectl get ingress task-manager-ingress

INGRESS_HOST=$(kubectl get ingress task-manager-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "📌 Ingress host: $INGRESS_HOST"

echo "📌 Curl check:"
curl -I "http://${INGRESS_HOST}/" || true

echo "📌 Logs:"
kubectl logs -l app=task-manager --tail=50
