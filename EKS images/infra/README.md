# eks-infra

AWS EKS Infrastructure — Terraform

## Structure
```
terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars        # gitignored — create locally
└── modules/
    ├── vpc/
    ├── eks/
    ├── iam_roles/
    ├── iam_irsa/
    ├── rds/
    └── secrets/
```

## Deploy

```bash
# 1. terraform.tfvars banao
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# db_password set karo

# 2. Deploy
cd terraform/
terraform init
terraform apply -auto-approve
```

## Destroy

```bash
terraform destroy -auto-approve
```
