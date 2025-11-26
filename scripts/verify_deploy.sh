#!/usr/bin/env bash
set -e

echo "======================================"
echo " 🔍 VERIFYING DEPLOYMENT STATUS"
echo "======================================"

echo ""
echo "📌 Checking Pods:"
kubectl get pods -l app=task-manager -o wide
echo ""

echo "📌 Checking Services:"
kubectl get svc task-manager-svc
kubectl get svc task-manager-svc-green
echo ""

echo "📌 Getting Ingress Host..."
# Try hostname first (AWS ALB usually gives hostname, not IP)
INGRESS_HOST=$(kubectl get ingress task-manager-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)

# Fallback to IP (rarely used)
if [[ -z "$INGRESS_HOST" ]]; then
  INGRESS_HOST=$(kubectl get ingress task-manager-ingress \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
fi

if [[ -z "$INGRESS_HOST" ]]; then
  echo "❌ No Ingress hostname found! Is the ALB still provisioning?"
  exit 1
else
  echo "🌐 Ingress Host:  http://$INGRESS_HOST"
fi
echo ""

echo "======================================"
echo " 🌐 Testing ALB HTTP Response"
echo "======================================"

curl -I "http://${INGRESS_HOST}/" || true
echo ""

echo "======================================"
echo " 🩺 HEALTH CHECK – BLUE PODS"
echo "======================================"
kubectl get pods -l "app=task-manager,version=blue" -o wide || true
echo ""

BLUE_POD=$(kubectl get pods -l "app=task-manager,version=blue" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [[ -n "$BLUE_POD" ]]; then
  echo "➡ Testing /health (BLUE)"
  kubectl exec "$BLUE_POD" -- curl -s localhost:5000/health || true
fi
echo ""

echo "======================================"
echo " 🩺 HEALTH CHECK – GREEN PODS"
echo "======================================"
kubectl get pods -l "app=task-manager,version=green" -o wide || true
echo ""

GREEN_POD=$(kubectl get pods -l "app=task-manager,version=green" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [[ -n "$GREEN_POD" ]]; then
  echo "➡ Testing /health (GREEN)"
  kubectl exec "$GREEN_POD" -- curl -s localhost:5000/health || true
fi
echo ""

echo "======================================"
echo " 📜 Recent Logs (Blue & Green)"
echo "======================================"
kubectl logs -l app=task-manager --tail=100
echo ""

echo "✅ Verification complete!"
