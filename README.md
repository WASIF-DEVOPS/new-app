# 🚀 Secure DevOps Infrastructure on AWS EKS

## 📋 Project Overview

A complete, secure, and scalable DevOps infrastructure for development teams using **Terraform**, **AWS EKS**, and **Jenkins**. All services are accessible only via VPN — ensuring a production-grade secure environment.

---

## 🏗️ Architecture Diagram

```
                          ┌─────────────────────────────────────────────────────────────┐
                          │                        AWS Cloud (us-east-1)                 │
                          │                                                               │
                          │   ┌─────────────────────────────────────────────────────┐   │
                          │   │              VPC  (10.0.0.0/16)                      │   │
                          │   │                                                       │   │
                          │   │  ┌──────────────────┐  ┌──────────────────┐         │   │
                          │   │  │  Public Subnet    │  │  Public Subnet   │         │   │
                          │   │  │  us-east-1a       │  │  us-east-1b      │         │   │
                          │   │  │  10.0.101.0/24    │  │  10.0.102.0/24   │         │   │
                          │   │  │                   │  │                  │         │   │
                          │   │  │  ┌─────────────┐  │  │                  │         │   │
                          │   │  │  │  AWS Client │  │  │  ┌───────────┐  │         │   │
                          │   │  │  │  VPN        │  │  │  │ Internet  │  │         │   │
                          │   │  │  │  Endpoint   │  │  │  │ Gateway   │  │         │   │
                          │   │  │  │172.16.0.0/22│  │  │  └───────────┘  │         │   │
                          │   │  │  └─────────────┘  │  │                  │         │   │
                          │   │  │  ┌─────────────┐  │  │                  │         │   │
                          │   │  │  │  NAT        │  │  │                  │         │   │
                          │   │  │  │  Gateway    │  │  │                  │         │   │
                          │   │  │  └─────────────┘  │  │                  │         │   │
                          │   │  └──────────────────┘  └──────────────────┘         │   │
                          │   │                                                       │   │
                          │   │  ┌──────────────────┐  ┌──────────────────┐         │   │
                          │   │  │  Private Subnet   │  │  Private Subnet  │         │   │
                          │   │  │  us-east-1a       │  │  us-east-1b      │         │   │
                          │   │  │  10.0.1.0/24      │  │  10.0.2.0/24     │         │   │
                          │   │  │                   │  │                  │         │   │
                          │   │  │  ┌─────────────┐  │  │ ┌─────────────┐ │         │   │
                          │   │  │  │ EKS Node    │  │  │ │ EKS Node    │ │         │   │
                          │   │  │  │ (jenkins-   │  │  │ │ (jenkins-   │ │         │   │
                          │   │  │  │  app-ng)    │  │  │ │  agents-ng) │ │         │   │
                          │   │  │  │ t3.small    │  │  │ │ t3.small    │ │         │   │
                          │   │  │  │             │  │  │ │             │ │         │   │
                          │   │  │  │ ┌─────────┐ │  │  │ │ ┌─────────┐ │ │         │   │
                          │   │  │  │ │ Jenkins │ │  │  │ │ │ Jenkins │ │ │         │   │
                          │   │  │  │ │  Pod    │ │  │  │ │ │  Agent  │ │ │         │   │
                          │   │  │  │ └─────────┘ │  │  │ │ └─────────┘ │ │         │   │
                          │   │  │  │ ┌─────────┐ │  │  │ │             │ │         │   │
                          │   │  │  │ │  Web    │ │  │  │ │             │ │         │   │
                          │   │  │  │ │  Pod    │ │  │  │ │             │ │         │   │
                          │   │  │  │ └─────────┘ │  │  │ │             │ │         │   │
                          │   │  │  │ ┌─────────┐ │  │  │ │             │ │         │   │
                          │   │  │  │ │  App    │ │  │  │ │             │ │         │   │
                          │   │  │  │ │  Pod    │ │  │  │ │             │ │         │   │
                          │   │  │  │ └─────────┘ │  │  │ │             │ │         │   │
                          │   │  │  │ ┌─────────┐ │  │  │ │             │ │         │   │
                          │   │  │  │ │  MySQL  │ │  │  │ │             │ │         │   │
                          │   │  │  │ │  Pod    │ │  │  │ │             │ │         │   │
                          │   │  │  │ └─────────┘ │  │  │ │             │ │         │   │
                          │   │  │  └─────────────┘  │  │ └─────────────┘ │         │   │
                          │   │  └──────────────────┘  └──────────────────┘         │   │
                          │   │                                                       │   │
                          │   │  ┌─────────────────────────────────────────────┐     │   │
                          │   │  │           ALB (Internal)                     │     │   │
                          │   │  │  jenkins.domain.com  |  dev.domain.com       │     │   │
                          │   │  └─────────────────────────────────────────────┘     │   │
                          │   └─────────────────────────────────────────────────┘   │   │
                          │                                                           │   │
                          │   ┌──────────┐   ┌──────────┐   ┌──────────────────┐   │   │
                          │   │   ECR    │   │   IAM    │   │      ACM         │   │   │
                          │   │ three-   │   │  Roles & │   │  Certificates    │   │   │
                          │   │ tier-web │   │  Policies│   │  (VPN Server +   │   │   │
                          │   │ three-   │   │          │   │   Client)        │   │   │
                          │   │ tier-app │   │          │   │                  │   │   │
                          │   └──────────┘   └──────────┘   └──────────────────┘   │   │
                          └─────────────────────────────────────────────────────────┘   │
                                                                                         │
Developer Machine ────── VPN (172.16.0.0/22) ──────────────────────────────────────────┘
(AWS VPN Client)
```

---

## 🔧 Infrastructure Components

### Networking (VPC)
| Resource | Value |
|----------|-------|
| VPC CIDR | `10.0.0.0/16` |
| Public Subnets | `10.0.101.0/24`, `10.0.102.0/24` |
| Private Subnets | `10.0.1.0/24`, `10.0.2.0/24` |
| Availability Zones | `us-east-1a`, `us-east-1b` |
| NAT Gateway | Single (Public Subnet) |

### EKS Cluster
| Resource | Value |
|----------|-------|
| Cluster Name | `dev-eks-cluster` |
| Kubernetes Version | `1.30` |
| Node Group 1 | `jenkins-app-ng` — `t3.small` (1-4 nodes) |
| Node Group 2 | `jenkins-agents-ng` — `t3.small` (1-6 nodes) |
| Subnets | Private only |

### VPN
| Resource | Value |
|----------|-------|
| Type | AWS Client VPN |
| Client CIDR | `172.16.0.0/22` |
| Auth | Certificate-based (EasyRSA) |
| Split Tunnel | Enabled |
| Access | Full VPC `10.0.0.0/16` |

### IAM
| Role/User | Purpose |
|-----------|---------|
| `eks-cluster-role` | EKS Control Plane |
| `eks-node-role` | Worker Nodes (EKSWorkerNode, CNI, ECR) |
| `jenkins-ci-user` | CI/CD — ECR push + EKS describe |

---

## ⚙️ CI/CD Pipeline

```
Developer
    │
    ▼
GitHub (PR / Push)
    │
    ▼
Jenkins (jenkins.domain.com)  ◄── VPN Only
    │
    ├── Stage: Build
    │       Jenkins Agent Pod (role: jenkins-agent)
    │       docker build → three-tier-web / three-tier-app
    │
    ├── Stage: Push
    │       aws ecr get-login-password
    │       docker push → ECR
    │
    └── Stage: Deploy
            kubectl apply → EKS (app namespace)
```

---

## 🌐 Application Architecture (Three-Tier)

```
Browser (VPN Connected)
        │
        ▼
dev.domain.com
        │
        ▼
ALB Ingress (Internal) ── ALB Ingress Controller
        │
        ▼
┌───────────────┐
│  Web Layer    │  Flask (port 5000)  ← three-tier-web:latest
│  web-service  │  Namespace: app
└───────┬───────┘
        │ http://app-service:4000
        ▼
┌───────────────┐
│  App Layer    │  Flask (port 4000)  ← three-tier-app:latest
│  app-service  │  Namespace: app
└───────┬───────┘
        │ mysql-service:3306
        ▼
┌───────────────┐
│  Data Layer   │  MySQL (port 3306)
│ mysql-service │  Namespace: app
└───────────────┘
```

---

## 🔒 Security

- All workloads run in **private subnets**
- `dev.domain.com` and `jenkins.domain.com` accessible **via VPN only**
- ALB scheme: **internal**
- EKS nodes: **no public IPs**
- VPN auth: **mutual TLS (certificate-based)**
- Jenkins IAM user: **least privilege** (ECR + EKS only)

---

## 📁 Project Structure

```
EKS Project/
├── terraform/
│   ├── main.tf                  # Root module
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── vpc/                 # VPC, Subnets, NAT, IGW
│       ├── eks/                 # EKS Cluster + Node Groups
│       ├── iam/                 # Roles, Policies, Jenkins User
│       └── vpn/                 # Client VPN Endpoint
│
├── k8s/
│   ├── jenkins/                 # Jenkins Deployment + Service
│   ├── ingress/                 # Jenkins Ingress (jenkins.domain.com)
│   ├── jenkins-rbac.yaml        # ClusterRole + Binding
│   └── storageclass.yaml        # gp2-ebs StorageClass
│
├── jenkins/
│   ├── Jenkinsfile              # Main pipeline
│   └── agent/
│       └── Dockerfile           # Custom Jenkins Agent
│
├── k8s/app/three-tier-web-app/
│   ├── WebLayer/                # Flask Web (port 5000)
│   ├── ApplicationLayer/        # Flask App (port 4000)
│   ├── k8s/
│   │   ├── web-deployment.yaml
│   │   ├── app-deployment.yaml
│   │   ├── mysql-deployment.yaml
│   │   └── ingress.yaml         # dev.domain.com
│   └── Jenkinsfile              # App CI/CD pipeline
│
├── client-config.ovpn           # VPN Client Config
└── append-vpn-cert.ps1          # VPN Cert Script
```

---

## 🚀 Deployment Steps

### 1. Infrastructure Deploy
```bash
cd terraform/
terraform init
terraform apply -auto-approve
```

### 2. EKS Access Setup
```bash
aws eks update-kubeconfig --region us-east-1 --name dev-eks-cluster
```

### 3. Kubernetes Resources Apply
```bash
kubectl apply -f k8s/storageclass.yaml
kubectl apply -f k8s/jenkins-rbac.yaml
kubectl apply -f k8s/jenkins/jenkins.yaml
kubectl apply -f k8s/ingress/ingress.yaml
```

### 4. App Deploy
```bash
kubectl create namespace app
kubectl apply -f k8s/app/three-tier-web-app/k8s/
```

### 5. VPN Connect
```
AWS VPN Client → Load client-config.ovpn → Connect
```

### 6. Access
| Service | URL |
|---------|-----|
| Application | http://dev.domain.com |
| Jenkins | http://jenkins.domain.com |

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| IaC | Terraform |
| Container Orchestration | AWS EKS (Kubernetes 1.29) |
| CI/CD | Jenkins |
| Container Registry | AWS ECR |
| Networking | AWS VPC, Client VPN |
| Load Balancer | AWS ALB (Ingress Controller) |
| App Framework | Python Flask |
| Database | MySQL |
| Certificates | EasyRSA, AWS ACM |
| OS | Amazon Linux 2 |

---

## ✅ Project Status

| Component | Status |
|-----------|--------|
| VPC + Networking | ✅ Complete |
| EKS Cluster | ✅ Complete |
| Node Groups (x2) | ✅ Complete |
| IAM Roles & Policies | ✅ Complete |
| AWS Client VPN | ✅ Complete |
| ALB Ingress Controller | ✅ Complete |
| Jenkins Deployment | ✅ Complete |
| Jenkins CI/CD Pipeline | ✅ Complete |
| Three-Tier App | ✅ Complete |
| ECR Repositories | ✅ Complete |
| dev.domain.com | ✅ Complete |
| jenkins.domain.com | ✅ Complete |
