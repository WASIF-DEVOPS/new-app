# EKS Project — Architecture Diagram (Updated — Verified against Terraform & K8s manifests)

## Full Infrastructure Diagram

```
Region: us-east-1
┌──────────────────────────────────────────────────────────────────────────────────┐
│  AWS Account: 175200623112                                                       │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────────┐  │
│  │  VPC: dev-vpc  (10.0.0.0/16)                                               │  │
│  │                                                                            │  │
│  │  ┌──────────────────────────┐     ┌──────────────────────────┐            │  │
│  │  │  AZ: us-east-1a          │     │  AZ: us-east-1b          │            │  │
│  │  │                          │     │                          │            │  │
│  │  │  ┌────────────────────┐  │     │  ┌────────────────────┐  │            │  │
│  │  │  │  Public Subnet     │  │     │  │  Public Subnet     │  │            │  │
│  │  │  │  10.0.101.0/24     │  │     │  │  10.0.102.0/24     │  │            │  │
│  │  │  │  ┌──────────────┐  │  │     │  └────────────────────┘  │            │  │
│  │  │  │  │ NAT Gateway  │  │  │     │                          │            │  │
│  │  │  │  └──────┬───────┘  │  │     │                          │            │  │
│  │  │  └─────────│──────────┘  │     │                          │            │  │
│  │  │            │             │     │                          │            │  │
│  │  │  ┌─────────▼──────────┐  │     │  ┌────────────────────┐  │            │  │
│  │  │  │  Private Subnet    │  │     │  │  Private Subnet    │  │            │  │
│  │  │  │  10.0.1.0/24       │  │     │  │  10.0.2.0/24       │  │            │  │
│  │  │  │                    │  │     │  │                    │  │            │  │
│  │  │  │  ┌──────────────┐  │  │     │  │  ┌──────────────┐  │  │            │  │
│  │  │  │  │jenkins-app-ng│  │  │     │  │  │jenkins-app-ng│  │  │            │  │
│  │  │  │  │t3.small x2   │  │  │     │  │  │t3.small x2   │  │  │            │  │
│  │  │  │  └──────────────┘  │  │     │  │  └──────────────┘  │  │            │  │
│  │  │  │  ┌──────────────┐  │  │     │  │  ┌──────────────┐  │  │            │  │
│  │  │  │  │jenkins-agents│  │  │     │  │  │jenkins-agents│  │  │            │  │
│  │  │  │  │t3.small x1   │  │  │     │  │  │t3.small x1   │  │  │            │  │
│  │  │  │  └──────────────┘  │  │     │  │  └──────────────┘  │  │            │  │
│  │  │  └────────────────────┘  │     │  └────────────────────┘  │            │  │
│  │  └──────────────────────────┘     └──────────────────────────┘            │  │
│  │                                                                            │  │
│  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │  │  EKS Cluster: dev-eks-cluster (v1.30)  🔒 Private Endpoint Only    │  │  │
│  │  │                                                                     │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │  Namespace: jenkins                                          │  │  │  │
│  │  │  │  ┌─────────────────────┐   ┌──────────────────────────────┐ │  │  │  │
│  │  │  │  │  Jenkins Master     │   │  Jenkins Agent Pods          │ │  │  │  │
│  │  │  │  │  jenkins-app-ng     │──▶│  (Dynamic, on-demand)        │ │  │  │  │
│  │  │  │  │  PVC: 20Gi (gp2-ebs)│   │  jenkins-agents-ng           │ │  │  │  │
│  │  │  │  │  port: 8080, 50000  │   │  max: 6 pods                 │ │  │  │  │
│  │  │  │  │  SA: jenkins (IRSA) │   │  image: jenkins/inbound-agent│ │  │  │  │
│  │  │  │  │  cpu: 500m-1000m    │   │  tools: docker,kubectl,awscli│ │  │  │  │
│  │  │  │  │  mem: 1Gi-2Gi       │   └──────────────────────────────┘ │  │  │  │
│  │  │  │  └─────────────────────┘                                     │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────────────────┐    │  │  │  │
│  │  │  │  │  Internal ALB: jenkins.volo.pk  🔒 HTTPS (443)      │    │  │  │  │
│  │  │  │  │  HTTP→HTTPS redirect | ACM: *.volo.pk               │    │  │  │  │
│  │  │  │  └─────────────────────────────────────────────────────┘    │  │  │  │
│  │  │  └──────────────────────────────────────────────────────────┘  │  │  │  │
│  │  │                                                                 │  │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  Namespace: app                                          │  │  │  │  │
│  │  │  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────┐  │  │  │  │  │
│  │  │  │  │  Web Layer      │  │  App Layer      │  │  MySQL  │  │  │  │  │  │
│  │  │  │  │  replicas: 2    │─▶│  replicas: 2    │─▶│  x1     │  │  │  │  │  │
│  │  │  │  │  port: 5000     │  │  port: 4000     │  │  p:3306 │  │  │  │  │  │
│  │  │  │  │  cpu: 100-500m  │  │  cpu: 100-500m  │  │  PVC:   │  │  │  │  │  │
│  │  │  │  │  mem: 128-512Mi │  │  mem: 128-512Mi │  │  10Gi   │  │  │  │  │  │
│  │  │  │  └─────────────────┘  └─────────────────┘  └─────────┘  │  │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────────────────┐  │  │  │  │  │
│  │  │  │  │  Internal ALB: dev.volo.pk  🔒 HTTPS (443)          │  │  │  │  │  │
│  │  │  │  │  HTTP→HTTPS redirect | ACM: *.volo.pk               │  │  │  │  │  │
│  │  │  │  └─────────────────────────────────────────────────────┘  │  │  │  │  │
│  │  │  └──────────────────────────────────────────────────────────┘  │  │  │  │
│  │  │                                                                 │  │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  Namespace: monitoring                                   │  │  │  │  │
│  │  │  │  ┌─────────────────┐  ┌─────────────────┐               │  │  │  │  │
│  │  │  │  │  Prometheus     │  │  Grafana        │               │  │  │  │  │
│  │  │  │  │  port: 9090     │─▶│  port: 3000     │               │  │  │  │  │
│  │  │  │  │  kube-prometheus│  │  dashboards:    │               │  │  │  │  │
│  │  │  │  │  -stack         │  │  K8s Views      │               │  │  │  │  │
│  │  │  │  └─────────────────┘  └────────┬────────┘               │  │  │  │  │
│  │  │  │  ┌─────────────────┐           │ Alerts                 │  │  │  │  │
│  │  │  │  │  Alertmanager   │◀──────────┘                        │  │  │  │  │
│  │  │  │  │  port: 9093     │                                     │  │  │  │  │
│  │  │  │  └────────┬────────┘                                     │  │  │  │  │
│  │  │  │           │ Slack Webhook                                │  │  │  │  │
│  │  │  │           ▼                                              │  │  │  │  │
│  │  │  │  Slack #eks-alerts channel                               │  │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────────────┐    │  │  │  │  │
│  │  │  │  │  Internal ALB: prometheus.volo.pk 🔒 HTTPS(443) │    │  │  │  │  │
│  │  │  │  │  Internal ALB: grafana.volo.pk    🔒 HTTPS(443) │    │  │  │  │  │
│  │  │  │  │  HTTP→HTTPS redirect | ACM: *.volo.pk           │    │  │  │  │  │
│  │  │  │  └─────────────────────────────────────────────────┘    │  │  │  │  │
│  │  │  └──────────────────────────────────────────────────────┘  │  │  │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │  │  │
│  │                                                                    │  │  │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │  │  │
│  │  │  AWS Client VPN  (172.16.0.0/22)  🔒 Certificate Auth (ACM) │  │  │  │  │
│  │  │  Split Tunnel: ON  |  Route: 10.0.0.0/16 → VPC              │  │  │  │  │
│  │  │  Logging: CloudWatch /aws/vpn/dev-team (30 days retention)  │  │  │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │  │  │
│  └────────────────────────────────────────────────────────────────────┘  │  │  │
│                                                                           │  │  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │  │  │
│  │  ACM Certificates                                                   │  │  │  │
│  │  ┌──────────────────────────────┐  ┌──────────────────────────┐    │  │  │  │
│  │  │  *.volo.pk (Wildcard)        │  │  VPN Server Certificate  │    │  │  │  │
│  │  │  HTTPS for all services      │  │  Certificate-based auth  │    │  │  │  │
│  │  │  DNS validated (Cloudflare)  │  └──────────────────────────┘    │  │  │  │
│  │  └──────────────────────────────┘                                  │  │  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │  │  │
│                                                                           │  │  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │  │  │
│  │  IAM  🔒                                                            │  │  │  │
│  │  EKS Cluster Role | EKS Node Role | Jenkins IRSA | ALB IRSA        │  │  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │  │  │
│                                                                           │  │  │
│  ┌─────────────────────────────────────────────────────────────────────┐  │  │  │
│  │  ECR Repositories                                                   │  │  │  │
│  │  three-tier-web | three-tier-app | jenkins-agent                   │  │  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │  │  │
└───────────────────────────────────────────────────────────────────────────┘  │  │
                                                                                │
Developer Laptop ──── AWS VPN Client (172.16.0.0/22) ──────────────────────────┘
```

---

## Monitoring Stack

```
Prometheus (prometheus.volo.pk) 🔒 HTTPS
    │
    ├── Node Exporter (CPU, Memory, Disk, Network)
    ├── Kube State Metrics (Pod, Deployment status)
    └── Alertmanager
            │
            ▼
        Grafana (grafana.volo.pk) 🔒 HTTPS
            │  Dashboards:
            ├── Kubernetes / Views / Pods
            ├── Kubernetes / Views / Global
            └── Kubernetes / Views / Nodes
            │
            │  Alert Rules:
            ├── High CPU Usage    → fires when CPU > 80%
            └── High Memory Usage → fires when Memory > 90%
                    │
                    ▼
            Slack #eks-alerts
            Repeat interval: 15s
```

---

## Application — Todo List App

```
Access URL: https://dev.volo.pk  (via VPN only) 🔒 HTTPS

Web Layer (Flask — port 5000)
  Routes: GET / | POST /api/create | POST /api/update | POST /api/complete
  APP_URL: http://app-service:4000

App Layer (Flask — port 4000)
  Routes: GET / | POST /create | POST /update | POST /complete/<id> | GET /health
  DB: MySQL via env vars (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME)

MySQL (port 3306)
  Database: todotable | PVC: 10Gi gp2-ebs
  Credentials: K8s Secret db-secret
```

---

## CI/CD Pipeline Flow

```
Developer → GitHub → Jenkins (https://jenkins.volo.pk) 🔒 HTTPS
    │
    ▼
Jenkins Agent Pod
    ├── Stage 1: Build  → docker build three-tier-web + three-tier-app
    ├── Stage 2: Test   → run test suite
    ├── Stage 3: Push   → ECR push (Git SHA tag)
    └── Stage 4: Deploy → kubectl apply → EKS namespace: app
```

---

## Network Access Flow (VPN + HTTPS)

```
Developer Laptop
    │
    │  AWS VPN Client — cert auth | 172.16.0.0/22 → split tunnel
    ▼
VPC 10.0.0.0/16
    │
    ├──▶ https://jenkins.volo.pk    🔒 HTTPS (443) → Jenkins Pod :8080
    ├──▶ https://dev.volo.pk        🔒 HTTPS (443) → Web Pod :5000 → App :4000 → MySQL :3306
    ├──▶ https://grafana.volo.pk    🔒 HTTPS (443) → Grafana Pod :3000
    └──▶ https://prometheus.volo.pk 🔒 HTTPS (443) → Prometheus Pod :9090
```

---

## Infrastructure Summary

| Component | Detail | Status |
|-----------|--------|--------|
| Region | us-east-1 | ✅ |
| VPC CIDR | 10.0.0.0/16 | ✅ |
| Public Subnets | 10.0.101.0/24, 10.0.102.0/24 | ✅ |
| Private Subnets | 10.0.1.0/24, 10.0.2.0/24 | ✅ |
| EKS Version | 1.30 | ✅ |
| EKS Endpoint | Private only 🔒 | ✅ |
| Node Group 1 | jenkins-app-ng — t3.small (desired:2, max:4) | ✅ |
| Node Group 2 | jenkins-agents-ng — t3.small (desired:1, max:6) | ✅ |
| VPN CIDR | 172.16.0.0/22 — split tunnel | ✅ |
| VPN Auth | Certificate-based (ACM) 🔒 | ✅ |
| ACM Certificate | *.volo.pk wildcard (DNS validated via Cloudflare) | ✅ |
| HTTPS | All services (Jenkins, App, Grafana, Prometheus) | ✅ |
| HTTP→HTTPS Redirect | ALB ssl-redirect: 443 | ✅ |
| Jenkins PVC | 20Gi gp2-ebs | ✅ |
| Jenkins Resources | cpu: 500m-1000m, mem: 1Gi-2Gi | ✅ |
| MySQL PVC | 10Gi gp2-ebs | ✅ |
| Prometheus | kube-prometheus-stack (Helm) | ✅ |
| Grafana | Dashboards: K8s Views (Pods, Global, Nodes) | ✅ |
| Alert: High CPU | Fires > 80% | ✅ |
| Alert: High Memory | Fires > 90% | ✅ |
| Slack Alerts | #eks-alerts channel, repeat: 15s | ✅ |
| DNS | Cloudflare (dev, jenkins, grafana, prometheus) | ✅ |
| IAM Jenkins | IRSA Role — ECR push/pull + eks:DescribeCluster 🔒 | ✅ |
| IAM ALB Controller | IRSA Role — AWSLoadBalancerControllerIAMPolicy 🔒 | ✅ |
| ECR Repos | three-tier-web, three-tier-app, jenkins-agent | ✅ |
| Image Tagging | Git commit SHA | ✅ |

---

## Security Checklist

| Check | Status |
|-------|--------|
| EKS public endpoint disabled | ✅ |
| VPN certificate-based auth | ✅ |
| All services HTTPS only | ✅ |
| ACM wildcard certificate | ✅ |
| HTTP → HTTPS redirect | ✅ |
| Internal ALB only | ✅ |
| Private subnets for EKS nodes | ✅ |
| Jenkins IAM least privilege | ✅ |
| DB credentials in K8s Secrets | ✅ |
| Jenkins RBAC least privilege | ✅ |
| tfstate not in Git | ✅ |
| VPN keys/certs not in Git | ✅ |
| tfvars not in Git | ✅ |
| Monitoring alerts (CPU + Memory) | ✅ |
| Slack alert notifications | ✅ |
