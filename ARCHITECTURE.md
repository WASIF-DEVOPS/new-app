# EKS Project — Architecture Diagram (Updated)

## Full Infrastructure Diagram

```
Region: us-east-1
┌──────────────────────────────────────────────────────────────────────────────────┐
│  AWS Account: 447777058729                                                       │
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
│  │  │  │  │ 18.235.57.123│  │  │     │                          │            │  │
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
│  │  │  Control Plane Logs: api, audit, authenticator, scheduler, ctrl-mgr │  │  │
│  │  │                                                                     │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │  Namespace: jenkins                                          │  │  │  │
│  │  │  │                                                              │  │  │  │
│  │  │  │  ┌─────────────────────┐   ┌──────────────────────────────┐ │  │  │  │
│  │  │  │  │  Jenkins Master     │   │  Jenkins Agent Pods          │ │  │  │  │
│  │  │  │  │  jenkins-app-ng     │──▶│  (Dynamic, on-demand)        │ │  │  │  │
│  │  │  │  │  PVC: 20Gi (gp2)   │   │  jenkins-agents-ng           │ │  │  │  │
│  │  │  │  │  port: 8080         │   │  max: 6 pods                 │ │  │  │  │
│  │  │  │  └─────────────────────┘   └──────────────────────────────┘ │  │  │  │
│  │  │  │         │                                                    │  │  │  │
│  │  │  │  ┌──────▼──────────────────────────────────────────────┐    │  │  │  │
│  │  │  │  │  Internal ALB: jenkins.domain.com  (port 80)        │    │  │  │  │
│  │  │  │  │  internal-k8s-jenkins-devingre-...elb.amazonaws.com │    │  │  │  │
│  │  │  │  └─────────────────────────────────────────────────────┘    │  │  │  │
│  │  │  └──────────────────────────────────────────────────────────┘  │  │  │  │
│  │  │                                                                 │  │  │  │
│  │  │  ┌──────────────────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  Namespace: app                                          │  │  │  │  │
│  │  │  │                                                          │  │  │  │  │
│  │  │  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────┐  │  │  │  │  │
│  │  │  │  │  Web Layer      │  │  App Layer      │  │  MySQL  │  │  │  │  │  │
│  │  │  │  │  replicas: 2    │─▶│  replicas: 2    │─▶│  x1     │  │  │  │  │  │
│  │  │  │  │  port: 5000→80  │  │  port: 4000     │  │  p:3306 │  │  │  │  │  │
│  │  │  │  │  cpu: 100-500m  │  │  cpu: 100-500m  │  │  PVC:   │  │  │  │  │  │
│  │  │  │  │  mem: 128-512Mi │  │  mem: 128-512Mi │  │  10Gi   │  │  │  │  │  │
│  │  │  │  │  probes: ✅     │  │  probes: ✅     │  │  probes │  │  │  │  │  │
│  │  │  │  └─────────────────┘  └─────────────────┘  │  ✅     │  │  │  │  │  │
│  │  │  │         ▲                                   └─────────┘  │  │  │  │  │
│  │  │  │  ┌──────┴──────────────────────────────────────────┐     │  │  │  │  │
│  │  │  │  │  Internal ALB: dev.domain.com  (port 80)        │     │  │  │  │  │
│  │  │  │  │  internal-k8s-app-appingre-...elb.amazonaws.com │     │  │  │  │  │
│  │  │  │  └─────────────────────────────────────────────────┘     │  │  │  │  │
│  │  │  └──────────────────────────────────────────────────────────┘  │  │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │  │
│  │                                                                        │  │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │  │
│  │  │  AWS Client VPN  (172.16.0.0/22)  🔒 Certificate Auth (ACM)    │  │  │  │
│  │  │  Split Tunnel: ON  |  Port: 443/UDP                             │  │  │  │
│  │  │  Route: 10.0.0.0/16 → VPC                                       │  │  │  │
│  │  │  Logging: CloudWatch /aws/vpn/dev-team (30 days retention)      │  │  │  │
│  │  │  Associations: subnet-05b30170 (pub-1a) + subnet-079018bc (prv-1b)│  │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │  │
│  └────────────────────────────────────────────────────────────────────────┘  │  │
│                                                                               │  │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  IAM  🔒                                                                │  │  │
│  │  ┌──────────────────────────┐  ┌────────────────────────────────────┐  │  │  │
│  │  │  EKS Cluster Role        │  │  EKS Node Role                     │  │  │  │
│  │  │  AmazonEKSClusterPolicy  │  │  AmazonEKSWorkerNodePolicy         │  │  │  │
│  │  └──────────────────────────┘  │  AmazonEKS_CNI_Policy              │  │  │  │
│  │                                │  AmazonEC2ContainerRegistryReadOnly│  │  │  │
│  │  ┌──────────────────────────┐  │  AmazonEBSCSIDriverPolicy          │  │  │  │
│  │  │  Jenkins CI User         │  └────────────────────────────────────┘  │  │  │
│  │  │  ecr:GetAuthorizationToken│                                          │  │  │
│  │  │  ecr:BatchCheckLayer...  │                                           │  │  │
│  │  │  ecr:PutImage            │                                           │  │  │
│  │  │  ecr:Push/Pull only      │                                           │  │  │
│  │  │  eks:DescribeCluster     │                                           │  │  │
│  │  └──────────────────────────┘                                           │  │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │  │
│                                                                               │  │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  ECR Repositories                                                       │  │  │
│  │  ┌─────────────────────────┐  ┌─────────────────────────┐              │  │  │
│  │  │  three-tier-app:9       │  │  three-tier-web:9        │              │  │  │
│  │  └─────────────────────────┘  └─────────────────────────┘              │  │  │
│  │  ┌─────────────────────────┐                                            │  │  │
│  │  │  jenkins-agent:latest   │                                            │  │  │
│  │  └─────────────────────────┘                                            │  │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │  │
│                                                                               │  │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  CloudWatch Logs                                                        │  │  │
│  │  ┌──────────────────────────────┐  ┌──────────────────────────────┐    │  │  │
│  │  │  /aws/vpn/dev-team           │  │  EKS Control Plane Logs      │    │  │  │
│  │  │  retention: 30 days          │  │  api, audit, authenticator   │    │  │  │
│  │  │  stream: connections         │  │  controllerManager, scheduler│    │  │  │
│  │  └──────────────────────────────┘  └──────────────────────────────┘    │  │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │  │
└───────────────────────────────────────────────────────────────────────────────┘  │
```

---

## CI/CD Pipeline Flow

```
Developer
    │
    │  Git Push / Pull Request
    ▼
GitHub (github.com/Stalker74/kubernetes-project)
    │
    │  Webhook Trigger
    ▼
Jenkins Master (EKS — jenkins-app-ng)
    │
    │  Spawns dynamic agent pod (jenkins-agents-ng)
    ▼
┌─────────────────────────────────────────────────────┐
│  Jenkins Agent Pod                                  │
│                                                     │
│  Stage 1: Build                                     │
│  ├── docker build three-tier-web:$GIT_SHA           │
│  └── docker build three-tier-app:$GIT_SHA           │
│                                                     │
│  Stage 2: Test                                      │
│  └── run test suite                                 │
│                                                     │
│  Stage 3: Push                                      │
│  ├── aws ecr get-login-password                     │
│  ├── docker push three-tier-web:$GIT_SHA → ECR      │
│  └── docker push three-tier-app:$GIT_SHA → ECR      │
│                                                     │
│  Stage 4: Deploy                                    │
│  ├── aws eks update-kubeconfig                      │
│  ├── sed replace IMAGE_TAG in yamls                 │
│  └── kubectl apply -f k8s/app/                      │
│                                                     │
│  Post: success → log tag                            │
│        failure → log branch + tag                   │
│        always  → cleanWs()                          │
└─────────────────────────────────────────────────────┘
    │
    ▼
EKS Cluster — Namespace: app
  Web (x2) + App (x2) + MySQL (x1) updated
```

---

## Network Access Flow (VPN)

```
Developer Laptop
    │
    │  AWS VPN Client — cert auth (ACM)
    │  172.16.0.0/22 → split tunnel
    ▼
Client VPN Endpoint
    │  cvpn-endpoint-074db9ecabd2dfc3f
    │  Logs → CloudWatch /aws/vpn/dev-team
    ▼
VPC 10.0.0.0/16
    │
    ├──▶ Jenkins ALB (jenkins.domain.com:80)
    │         └──▶ Jenkins Pod :8080
    │
    └──▶ App ALB (dev.domain.com:80)
              └──▶ Web Pod :5000
                        └──▶ App Pod :4000
                                  └──▶ MySQL Pod :3306
                                            └──▶ PVC 10Gi (gp2)
```

---

## Infrastructure Summary

| Component | Detail | Status |
|-----------|--------|--------|
| Region | us-east-1 | ✅ |
| VPC CIDR | 10.0.0.0/16 | ✅ |
| Public Subnets | 10.0.101.0/24, 10.0.102.0/24 | ✅ |
| Private Subnets | 10.0.1.0/24, 10.0.2.0/24 | ✅ |
| NAT Gateway | Single — us-east-1a (18.235.57.123) | ✅ |
| EKS Version | 1.30 | ✅ |
| EKS Endpoint | Private only 🔒 | ✅ |
| EKS Logs | api, audit, authenticator, scheduler, ctrl-mgr | ✅ |
| Node Group 1 | jenkins-app-ng — t3.small (desired:2, max:4) | ✅ |
| Node Group 2 | jenkins-agents-ng — t3.small (desired:1, max:6) | ✅ |
| VPN CIDR | 172.16.0.0/22 — split tunnel | ✅ |
| VPN Auth | Certificate-based (ACM) | ✅ |
| VPN Logging | CloudWatch — 30 days retention | ✅ |
| Jenkins PVC | 20Gi gp2 | ✅ |
| MySQL PVC | 10Gi gp2 | ✅ |
| Web Replicas | 2 + resource limits + probes | ✅ |
| App Replicas | 2 + resource limits + probes | ✅ |
| IAM Jenkins | ECR push/pull only — no delete 🔒 | ✅ |
| Image Tagging | Git commit SHA | ✅ |
| CI/CD | Jenkins on EKS — dynamic agents | ✅ |

---

## Security Checklist

| Check | Status |
|-------|--------|
| EKS public endpoint disabled | ✅ |
| EKS control plane logging enabled | ✅ |
| VPN certificate-based auth | ✅ |
| VPN connection logging | ✅ |
| Jenkins IAM least privilege | ✅ |
| DB credentials in K8s Secrets | ✅ |
| tfstate not in Git | ✅ |
| VPN keys/certs not in Git | ✅ |
| Private subnets for EKS nodes | ✅ |
| Internal ALB only | ✅ |
