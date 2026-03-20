# EKS Project — Architecture Diagram

## Overview

```
Region: us-east-1
┌─────────────────────────────────────────────────────────────────────────────┐
│  AWS Account                                                                │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  VPC: dev-vpc  (10.0.0.0/16)                                         │  │
│  │                                                                      │  │
│  │  ┌─────────────────────────┐  ┌─────────────────────────┐           │  │
│  │  │  AZ: us-east-1a         │  │  AZ: us-east-1b         │           │  │
│  │  │                         │  │                         │           │  │
│  │  │  Public Subnet          │  │  Public Subnet          │           │  │
│  │  │  10.0.101.0/24          │  │  10.0.102.0/24          │           │  │
│  │  │  ┌─────────────────┐    │  │                         │           │  │
│  │  │  │  NAT Gateway    │    │  │                         │           │  │
│  │  │  └────────┬────────┘    │  │                         │           │  │
│  │  │           │             │  │                         │           │  │
│  │  │  Private Subnet         │  │  Private Subnet         │           │  │
│  │  │  10.0.1.0/24            │  │  10.0.2.0/24            │           │  │
│  │  │  ┌─────────────────┐    │  │  ┌─────────────────┐   │           │  │
│  │  │  │  EKS Node Group │    │  │  │  EKS Node Group │   │           │  │
│  │  │  │  jenkins-app-ng │    │  │  │  jenkins-app-ng │   │           │  │
│  │  │  │  (t3.small x2)  │    │  │  │  (t3.small x2)  │   │           │  │
│  │  │  └─────────────────┘    │  │  └─────────────────┘   │           │  │
│  │  │  ┌─────────────────┐    │  │  ┌─────────────────┐   │           │  │
│  │  │  │  EKS Node Group │    │  │  │  EKS Node Group │   │           │  │
│  │  │  │  jenkins-agents │    │  │  │  jenkins-agents │   │           │  │
│  │  │  │  (t3.small x1)  │    │  │  │  (t3.small x1)  │   │           │  │
│  │  │  └─────────────────┘    │  │  └─────────────────┘   │           │  │
│  │  └─────────────────────────┘  └─────────────────────────┘           │  │
│  │                                                                      │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │  EKS Cluster: dev-eks-cluster  (v1.29)                        │  │  │
│  │  │                                                               │  │  │
│  │  │  ┌─────────────────────────────────────────────────────────┐ │  │  │
│  │  │  │  Namespace: jenkins                                     │ │  │  │
│  │  │  │  ┌──────────────────┐   ┌──────────────────────────┐   │ │  │  │
│  │  │  │  │  Jenkins Master  │   │  Jenkins Agent Pods      │   │ │  │  │
│  │  │  │  │  (Node: jenkins- │──▶│  (Dynamic, on-demand)    │   │ │  │  │
│  │  │  │  │   app-ng)        │   │  (Node: jenkins-agents)  │   │ │  │  │
│  │  │  │  └──────────────────┘   └──────────────────────────┘   │ │  │  │
│  │  │  └─────────────────────────────────────────────────────────┘ │  │  │
│  │  │                                                               │  │  │
│  │  │  ┌─────────────────────────────────────────────────────────┐ │  │  │
│  │  │  │  Namespace: app                                         │ │  │  │
│  │  │  │                                                         │ │  │  │
│  │  │  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  │ │  │  │
│  │  │  │  │  Web Layer   │  │  App Layer   │  │  MySQL DB   │  │ │  │  │
│  │  │  │  │  (port 80)   │─▶│  (port 4000) │─▶│  (port 3306)│  │ │  │  │
│  │  │  │  │  web-service │  │  app-service │  │  mysql-svc  │  │ │  │  │
│  │  │  │  └──────────────┘  └──────────────┘  └─────────────┘  │ │  │  │
│  │  │  │         ▲                                               │ │  │  │
│  │  │  │  ┌──────────────────────────────────────────────────┐  │ │  │  │
│  │  │  │  │  ALB Ingress (internal)                          │  │ │  │  │
│  │  │  │  │  host: dev.domain.com                            │  │ │  │  │
│  │  │  │  └──────────────────────────────────────────────────┘  │ │  │  │
│  │  │  └─────────────────────────────────────────────────────────┘ │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  │                                                                      │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │  AWS Client VPN Endpoint  (172.16.0.0/22)                     │  │  │
│  │  │  Split Tunnel: ON  |  Auth: Certificate-based (ACM)           │  │  │
│  │  │  Associations: Public Subnet (1a) + Private Subnet (1b)       │  │  │
│  │  │  Route: 10.0.0.0/16  →  VPC                                   │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  IAM                                                                 │  │
│  │  ┌─────────────────────────┐  ┌──────────────────────────────────┐  │  │
│  │  │  EKS Cluster Role       │  │  EKS Node Role                   │  │  │
│  │  │  AmazonEKSClusterPolicy │  │  AmazonEKSWorkerNodePolicy       │  │  │
│  │  └─────────────────────────┘  │  AmazonEKS_CNI_Policy            │  │  │
│  │                               │  AmazonEC2ContainerRegistryRO    │  │  │
│  │  ┌─────────────────────────┐  └──────────────────────────────────┘  │  │
│  │  │  Jenkins CI User        │                                         │  │
│  │  │  ECR: full access       │                                         │  │
│  │  │  EKS: DescribeCluster   │                                         │  │
│  │  └─────────────────────────┘                                         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  ECR Repositories                                                    │  │
│  │  ┌──────────────────────────┐  ┌──────────────────────────────────┐ │  │
│  │  │  three-tier-app:latest   │  │  jenkins-agent:latest            │ │  │
│  │  └──────────────────────────┘  └──────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## CI/CD Flow

```
Developer
    │
    │  Git Push / Pull Request
    ▼
GitHub Repository
    │
    │  Webhook Trigger
    ▼
Jenkins Master (EKS - jenkins-app-ng)
    │
    │  Spawns dynamic agent pod
    ▼
Jenkins Agent Pod (EKS - jenkins-agents-ng)
    │
    ├─── Stage: Build
    │         docker build → image tagged
    │
    ├─── Stage: Test
    │         run tests
    │
    └─── Stage: Deploy
              aws ecr push → ECR
              kubectl apply → EKS (Namespace: app)
```

---

## Network Flow (User Access via VPN)

```
Developer Laptop
    │
    │  AWS VPN Client (cert-based auth)
    ▼
Client VPN Endpoint (172.16.0.0/22)
    │
    │  Split Tunnel → routes 10.0.0.0/16 through VPN
    ▼
VPC (10.0.0.0/16)
    │
    ▼
Internal ALB (dev.domain.com)
    │
    ▼
Web Layer Pod (port 80)
    │
    ▼
App Layer Pod (port 4000)
    │
    ▼
MySQL Pod (port 3306)
```

---

## Infrastructure Summary

| Component         | Detail                                      |
|-------------------|---------------------------------------------|
| Region            | us-east-1                                   |
| VPC CIDR          | 10.0.0.0/16                                 |
| Public Subnets    | 10.0.101.0/24, 10.0.102.0/24               |
| Private Subnets   | 10.0.1.0/24, 10.0.2.0/24                   |
| NAT Gateway       | Single, in us-east-1a                       |
| EKS Version       | 1.29                                        |
| Node Group 1      | jenkins-app-ng — t3.small (desired: 2, max: 4) |
| Node Group 2      | jenkins-agents-ng — t3.small (desired: 1, max: 6) |
| VPN CIDR          | 172.16.0.0/22 (split tunnel)               |
| VPN Auth          | Certificate-based (ACM)                     |
| App Ingress       | Internal ALB — dev.domain.com              |
| CI/CD             | Jenkins on EKS with dynamic agent pods      |
| Container Registry| Amazon ECR                                  |
