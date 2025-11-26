# Zero-Downtime Deployment System on AWS EKS

## Blue-Green + Canary Releases (Production-Grade DevOps Project)

This README contains **every single step**, **all commands**, and **clear explanations** required to build a real-world zero-downtime deployment system using:

* **AWS EKS (ap-south-1)**
* **Blue‑Green Deployments**
* **Canary Releases (via NGINX Ingress Canary annotations)**
* **Amazon ECR**
* **Docker**
* **Node.js Application**
* **Prometheus + Grafana + Alertmanager**
* **CI/CD using Jenkins**

It also includes instructions on creating **demo GIFs**, which you can use for LinkedIn, GitHub, or your resume.

---

# 📌 1. Project Overview

This project teaches you how real companies deploy applications **without downtime**, **without customer impact**, and with **automatic rollback**.

We will:

1. Build Docker images for v1 (Blue) and v2 (Green)
2. Push them to ECR
3. Deploy to EKS
4. Switch traffic instantly (Blue→Green) OR gradually (Canary)
5. Monitor everything with Prometheus & Grafana
6. Automate EVERYTHING with a Jenkins pipeline

---

# ⚙️ 2. Prerequisites

Install on your machine:

```
AWS CLI v2
kubectl
eksctl
helm
Docker
Git
jq (optional)
```

Configure AWS:

```bash
aws configure
aws configure set region ap-south-1
```

Test:

```bash
aws sts get-caller-identity
```

---

# 🏗️ 3. Create EKS Cluster (ap-south-1)

```bash
eksctl create cluster \
  --name zero-downtime-cluster \
  --region ap-south-1 \
  --nodes 2 \
  --node-type t3.medium
```

Confirm:

```bash
kubectl get nodes
```

If needed:

```bash
aws eks --region ap-south-1 update-kubeconfig --name zero-downtime-cluster
```

---

# 🐳 4. Prepare Docker Images

### Build your Node app

```
docker build -t task-manager:v1 .
```

### Create ECR repo

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=ap-south-1
REPO_NAME=task-manager
ECR_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}

aws ecr create-repository --repository-name ${REPO_NAME} --region ${AWS_REGION} || true
```

### Login & Push

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker tag task-manager:v1 ${ECR_URI}:v1
docker push ${ECR_URI}:v1
```

Repeat for v2:

```
docker build -t task-manager:v2 .
docker tag task-manager:v2 ${ECR_URI}:v2
docker push ${ECR_URI}:v2
```

---

# ☸️ 5. Deploy to Kubernetes (Blue)

```bash
kubectl apply -f k8s/deployment-blue.yaml
kubectl apply -f k8s/service.yaml
```

Check:

```bash
kubectl get pods
kubectl get svc
```

Apply ingress:

```bash
kubectl apply -f k8s/ingress.yaml
kubectl get ingress
```

---

# 🟩 6. Deploy Green Version

```bash
kubectl apply -f k8s/deployment-green.yaml
kubectl rollout status deployment/task-manager-green
```

---

# 🔄 7. Blue‑Green Switch (Zero Downtime)

### Switch traffic to Green

```bash
kubectl patch svc task-manager-svc -p '{"spec":{"selector":{"app":"task-manager","version":"green"}}}'
```

### Rollback instantly

```bash
kubectl patch svc task-manager-svc -p '{"spec":{"selector":{"app":"task-manager","version":"blue"}}}'
```

---

# 🐤 8. Canary Deployment (Gradual Traffic)

Apply canary ingress:

```bash
kubectl apply -f k8s/ingress-canary.yaml
```

Update canary weight:

```bash
kubectl annotate ingress task-manager-canary \
  nginx.ingress.kubernetes.io/canary-weight="50" --overwrite
```

Remove canary (full rollout):

```bash
kubectl delete ingress task-manager-canary
```

---

# 📊 9. Install Prometheus + Grafana

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
   --namespace monitoring --create-namespace
```

Access Grafana:

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
```

Login:

```
Username: admin
Password: prom-operator
```

Add dashboards: Node Exporter, Pod metrics, Deployment metrics.

---

# 🚨 10. Add Alerting Rules

Apply:

```bash
kubectl apply -f k8s/prometheus-rules.yaml -n monitoring
```

---

# 🤖 11. Jenkins CI/CD Pipeline

### Pipeline Steps:

1. Checkout code
2. Build Docker image
3. Push to ECR
4. Deploy Green version
5. Run health checks
6. Switch traffic (optional)
7. Start Canary rollout (optional)

Place Jenkinsfile in:

```
jenkins/Jenkinsfile
```

Pipeline will:

* Build image automatically
* Push safely to ECR
* Deploy to EKS
* Rollout to green
* Allow Blue‑Green switch
* Optional Canary rollout

---

# 🧪 12. Failure Simulation Tests

### Crash a canary pod:

```bash
POD=$(kubectl get pod -l version=green -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD
```

### Cause latency:

(Advanced, optional)

### Cause 500 errors:

Modify app.js temporarily.

Prometheus should detect the issue → Alertmanager sends alert → Canary aborts.

---

# 🎥 13. Creating Demonstration GIFs

You can record GIFs for GitHub/LinkedIn:

### Recommended tool: **Peek** (Linux) or **ScreenToGIF** (Windows)

### Demo GIFs to Record:

1️⃣ **Blue Deployment running**

* Show pods
* Show service serving v1

2️⃣ **Rolling out Green**

* Show `kubectl apply`
* Show green pods becoming ready

3️⃣ **Blue→Green traffic switch**

* Show `kubectl patch svc`
* Show live curl output switching version

4️⃣ **Canary rollout**

* Show canary ingress weights 20→50→100

5️⃣ **Failure test & rollback**

* Crash a green pod
* See alerts
* Show traffic returning to Blue

6️⃣ **Grafana dashboards**

* CPU, Memory, Pod restarts
* Canary error spike

### Convert video→GIF

Use ffmpeg:

```bash
ffmpeg -i demo.mp4 demo.gif
```

---

# 📦 14. Clean Up

```bash
eksctl delete cluster --name zero-downtime-cluster --region ap-south-1
```

---

# 🏁 Done! Your project is complete.

This project is **interview-perfect**, **resume-perfect**, and **production-realistic**.

If you want:

* A ZIP containing all files
* GitHub README formatting
* Architecture PNGs/SVGs
* Jenkinsfile polishing
* Automated Canary using Flagger

Just tell me! 🚀
