# 🏗️ Architecture — Secure DevOps Infrastructure on AWS EKS

## 📐 High-Level Architecture

```
Developer Machine (Windows)
        │
        │  OpenVPN (UDP 1194)
        ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AWS Cloud (us-east-1)                        │
│                                                                   │
│   ┌───────────────────────────────────────────────────────────┐  │
│   │                  VPC (10.0.0.0/16)                         │  │
│   │                                                             │  │
│   │  ┌─────────────────────┐   ┌─────────────────────┐        │  │
│   │  │   Public Subnet      │   │   Public Subnet      │        │  │
│   │  │   us-east-1a         │   │   us-east-1b         │        │  │
│   │  │   10.0.101.0/24      │   │   10.0.102.0/24      │        │  │
│   │  │   ┌─────────────┐   │   │   ┌─────────────┐   │        │  │
│   │  │   │ NAT Gateway │   │   │   │  OpenVPN EC2 │   │        │  │
│   │  │   └─────────────┘   │   │   │  t3.micro    │   │        │  │
│   │  │   ┌─────────────┐   │   │   │  10.8.0.0/24 │   │        │  │
│   │  │   │   Internet  │   │   │   └─────────────┘   │        │  │
│   │  │   │   Gateway   │   │   └─────────────────────┘        │  │
│   │  │   └─────────────┘   │                                   │  │
│   │  └─────────────────────┘                                   │  │
│   │                                                             │  │
│   │  ┌─────────────────────┐   ┌─────────────────────┐        │  │
│   │  │   Private Subnet     │   │   Private Subnet     │        │  │
│   │  │   us-east-1a         │   │   us-east-1b         │        │  │
│   │  │   10.0.1.0/24        │   │   10.0.2.0/24        │        │  │
│   │  │                      │   │                      │        │  │
│   │  │  ┌────────────────┐  │   │  ┌────────────────┐  │        │  │
│   │  │  │ EKS Node       │  │   │  │ EKS Node       │  │        │  │
│   │  │  │ jenkins-app-ng │  │   │  │jenkins-agents  │  │        │  │
│   │  │  │ t3.medium      │  │   │  │ t3.medium      │  │        │  │
│   │  │  │ ┌────────────┐ │  │   │  │ ┌────────────┐ │  │        │  │
│   │  │  │ │  Jenkins   │ │  │   │  │ │  Jenkins   │ │  │        │  │
│   │  │  │ │    Pod     │ │  │   │  │ │  Agent Pod │ │  │        │  │
│   │  │  │ └────────────┘ │  │   │  │ └────────────┘ │  │        │  │
│   │  │  │ ┌────────────┐ │  │   │  └────────────────┘  │        │  │
│   │  │  │ │  Web Pod   │ │  │   └─────────────────────┘        │  │
│   │  │  │ └────────────┘ │  │                                   │  │
│   │  │  │ ┌────────────┐ │  │                                   │  │
│   │  │  │ │  App Pod   │ │  │                                   │  │
│   │  │  │ └────────────┘ │  │                                   │  │
│   │  │  └────────────────┘  │                                   │  │
│   │  └─────────────────────┘                                   │  │
│   │                                                             │  │
│   │  ┌─────────────────────────────────────────────────────┐   │  │
│   │  │           ALB (Internal) — HTTPS (443)               │   │  │
│   │  │  jenkins.volo.pk  │  dev.volo.pk                     │   │  │
│   │  │  grafana.volo.pk  │  prometheus.volo.pk              │   │  │
│   │  └─────────────────────────────────────────────────────┘   │  │
│   │                                                             │  │
│   │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │  │
│   │  │     RDS      │  │     ECR      │  │ Secrets Manager │  │  │
│   │  │  MySQL 8.0   │  │ three-tier-  │  │ dev/three-tier- │  │  │
│   │  │  db.t3.micro │  │ web/app      │  │ app/db          │  │  │
│   │  └──────────────┘  └──────────────┘  └─────────────────┘  │  │
│   └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│   ┌──────────┐  ┌──────────┐  ┌──────────────────────────────┐  │
│   │   IAM    │  │  Route53 │  │        ACM Certificates       │  │
│   │  Roles & │  │ Private  │  │  *.volo.pk (HTTPS)            │  │
│   │  IRSA    │  │  Zone    │  └──────────────────────────────┘  │
│   └──────────┘  └──────────┘                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌐 Network Architecture

| Component | CIDR | Description |
|-----------|------|-------------|
| VPC | `10.0.0.0/16` | Main VPC |
| Private Subnet A | `10.0.1.0/24` | EKS Nodes (us-east-1a) |
| Private Subnet B | `10.0.2.0/24` | EKS Nodes (us-east-1b) |
| Public Subnet A | `10.0.101.0/24` | NAT Gateway (us-east-1a) |
| Public Subnet B | `10.0.102.0/24` | OpenVPN EC2 (us-east-1b) |
| VPN Client CIDR | `10.8.0.0/24` | OpenVPN Clients |

---

## ☸️ EKS Cluster

| Resource | Value |
|----------|-------|
| Cluster Name | `dev-eks-cluster` |
| Kubernetes Version | `1.31` |
| Node Group 1 | `jenkins-app-ng` — `t3.medium` (1-2 nodes) |
| Node Group 2 | `jenkins-agents-ng` — `t3.medium` (2-3 nodes) |
| Endpoint | Private only |
| OIDC | Enabled (IRSA) |
| EBS CSI Driver | Enabled |

---

## 🔒 VPN

| Component | Value |
|-----------|-------|
| Type | OpenVPN (Self-hosted EC2) |
| Instance | `t3.micro` — Public Subnet B |
| Client CIDR | `10.8.0.0/24` |
| Protocol | UDP 1194 |
| DNS | AWS VPC DNS `10.0.0.2` |
| Route | `10.0.0.0/16` pushed to clients |

---

## 🗄️ Database

| Component | Value |
|-----------|-------|
| Engine | MySQL 8.0 |
| Instance | `db.t3.micro` |
| Storage | 20 GB |
| Endpoint | `dev-mysql.cmtgwe8q2w1g.us-east-1.rds.amazonaws.com` |
| Access | VPC only (port 3306) |
| Credentials | AWS Secrets Manager |

---

## 🔐 IAM Roles (IRSA)

| Role | Service Account | Permissions |
|------|----------------|-------------|
| `dev-eks-cluster-cluster-role` | EKS Control Plane | EKSClusterPolicy |
| `dev-eks-cluster-node-role` | EKS Nodes | WorkerNode, CNI, ECR |
| `dev-eks-cluster-jenkins-irsa` | `jenkins:jenkins` | ECR push, EKS describe |
| `dev-eks-cluster-app-irsa` | `app:app-sa` | Secrets Manager read |
| `dev-eks-cluster-alb-controller` | `kube-system:aws-load-balancer-controller` | ALB management |
| `dev-eks-cluster-ebs-csi-role` | `kube-system:ebs-csi-controller-sa` | EBS volumes |

---

## ⚙️ CI/CD Pipeline

```
GitHub Push (main branch)
        │
        ▼ pollSCM (every 5 min)
Jenkins (https://jenkins.volo.pk)
        │
        ├── Stage: Build
        │       Jenkins Agent Pod (jenkins-agents-ng)
        │       docker build → three-tier-web:$GIT_SHA
        │       docker build → three-tier-app:$GIT_SHA
        │
        ├── Stage: SonarQube Analysis
        │       sonar-scanner → sonarcloud.io
        │       Org: Stalker74
        │
        ├── Stage: Test
        │       pytest (|| true — non-blocking)
        │
        ├── Stage: Trivy Scan
        │       HIGH + CRITICAL vulnerabilities scan
        │       Web image + App image
        │
        ├── Stage: Push
        │       ECR login (IRSA)
        │       docker push → three-tier-web:$GIT_SHA + latest
        │       docker push → three-tier-app:$GIT_SHA + latest
        │
        ├── Stage: Deploy
        │       aws eks update-kubeconfig
        │       kubectl apply → namespaces
        │       kubectl apply → app + web deployments
        │
        └── Stage: Smoke Test
                kubectl rollout status web + app
```

---

## 🌐 Three-Tier Application

```
Browser (VPN Connected)
        │
        ▼
https://dev.volo.pk
        │
        ▼
ALB (Internal) ── AWS Load Balancer Controller
        │
        ▼
┌───────────────────┐
│    Web Layer      │  Flask (port 5000)
│    web-service    │  Image: three-tier-web:latest
│    2 replicas     │  Namespace: app
└────────┬──────────┘
         │ http://app-service:4000
         ▼
┌───────────────────┐
│    App Layer      │  Flask (port 4000)
│    app-service    │  Image: three-tier-app:latest
│    2 replicas     │  Namespace: app
└────────┬──────────┘
         │ mysql://dev-mysql.*.rds.amazonaws.com:3306
         ▼
┌───────────────────┐
│    Data Layer     │  MySQL 8.0
│    AWS RDS        │  DB: appdb
│                   │  User: appuser
└───────────────────┘
```

---

## 🌍 DNS & Ingress

| Service | URL | ALB |
|---------|-----|-----|
| Application | `https://dev.volo.pk` | Internal ALB |
| Jenkins | `https://jenkins.volo.pk` | Internal ALB |
| Grafana | `https://grafana.volo.pk` | Internal ALB |
| Prometheus | `https://prometheus.volo.pk` | Internal ALB |

- DNS: Route53 Private Hosted Zone (`volo.pk`)
- TLS: ACM Certificate (`*.volo.pk`)
- HTTP → HTTPS redirect enabled

---

## 📁 Project Structure

```
EKS images/
├── infra/
│   └── terraform/
│       ├── main.tf                    # Root — VPC, EKS, IAM, RDS, Secrets, Route53
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── modules/
│           ├── vpc/                   # VPC, Subnets, NAT, IGW
│           ├── eks/                   # EKS Cluster, Node Groups, OIDC, Security Groups
│           ├── iam_roles/             # Cluster Role, Node Role
│           ├── iam_irsa/              # Jenkins, App, ALB, EBS CSI IRSA Roles
│           ├── rds/                   # MySQL RDS Instance
│           └── secrets/               # Secrets Manager (DB credentials)
│
└── tier-app/
    ├── jenkins/
    │   ├── Jenkinsfile                # CI/CD Pipeline
    │   └── agent/
    │       └── dockerfile             # Custom Jenkins Agent
    ├── k8s/k8s/
    │   ├── namespaces.yaml            # app, monitoring namespaces
    │   ├── jenkins.yaml               # Jenkins Deployment + PVC + Service
    │   ├── jenkins-rbac.yaml          # ClusterRole + Binding
    │   ├── storageclass.yaml          # gp2-ebs StorageClass
    │   ├── ingress.yaml               # ALB Ingress (all services)
    │   ├── app-deployment.yaml        # App Layer Deployment + Service
    │   ├── web-deployment.yaml        # Web Layer Deployment + Service
    │   ├── mysql-deployment.yaml      # MySQL Deployment + Service
    │   └── app-serviceaccount.yaml    # App IRSA Service Account
    └── three-tier-web-app/
        ├── WebLayer/                  # Flask Web (port 5000)
        │   ├── app.py
        │   ├── dockerfile
        │   └── templates/
        └── ApplicationLayer/          # Flask App (port 4000)
            ├── app.py
            ├── dockerfile
            └── parameters.py
```

---

## ✅ Component Status

| Component | Status |
|-----------|--------|
| VPC + Networking | ✅ Complete |
| EKS Cluster (v1.31) | ✅ Complete |
| Node Groups (x2) | ✅ Complete |
| IAM Roles & IRSA | ✅ Complete |
| OpenVPN (EC2) | ✅ Complete |
| ALB Ingress Controller | ✅ Complete |
| HTTPS (ACM *.volo.pk) | ✅ Complete |
| Route53 Private Zone | ✅ Complete |
| RDS MySQL | ✅ Complete |
| Secrets Manager | ✅ Complete |
| EBS CSI Driver | ✅ Complete |
| Jenkins Deployment | ✅ Complete |
| Jenkins CI/CD Pipeline | ✅ Complete |
| Three-Tier App | ✅ Complete |
| ECR Repositories | ✅ Complete |
| SonarCloud Integration | ✅ Complete |
| Trivy Security Scanning | ✅ Complete |
| Prometheus + Grafana | 🔄 Pending |
| Slack Alerts | 🔄 Pending |
