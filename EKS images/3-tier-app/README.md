# three-tier-app

Three-Tier Flask Application — Web + App + MySQL (RDS)

## Structure
```
three-tier-web-app/
├── WebLayer/          # Flask Web (port 5000)
├── ApplicationLayer/  # Flask App (port 4000)
jenkins/
├── Jenkinsfile        # CI/CD Pipeline
└── agent/
    └── dockerfile     # Custom Jenkins Agent
k8s/
└── k8s/
    ├── web-deployment.yaml
    ├── app-deployment.yaml
    ├── mysql-deployment.yaml
    ├── secret-provider.yaml
    ├── sonarqube.yaml
    ├── hpa.yaml
    └── ingress.yaml
```

## Pipeline

```
Push → SonarQube → Test → Trivy → Push ECR → Deploy EKS → Smoke Test
```

## Access

| Service | URL |
|---------|-----|
| App | https://dev.volo.pk |
| Jenkins | https://jenkins.volo.pk |
| SonarQube | https://sonar.volo.pk |
| Grafana | https://grafana.volo.pk |
| Prometheus | https://prometheus.volo.pk |
