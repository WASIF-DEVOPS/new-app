terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket = "175200623112-terraform-state"
    key    = "eks-project/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}


data "aws_caller_identity" "current" {}

module "vpc" {
  source       = "./modules/vpc"
  vpc_name     = var.vpc_name
  cluster_name = var.cluster_name
}

module "iam_roles" {
  source       = "./modules/iam_roles"
  cluster_name = var.cluster_name
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  cluster_role_arn   = module.iam_roles.cluster_role_arn
  node_role_arn      = module.iam_roles.node_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password        = var.db_password
}

module "secrets" {
  source       = "./modules/secrets"
  db_password  = var.db_password
  rds_endpoint = module.rds.rds_endpoint
}

module "iam_irsa" {
  source            = "./modules/iam_irsa"
  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider
  account_id        = data.aws_caller_identity.current.account_id
  db_secret_arn     = module.secrets.secret_arn
}

# Route53 Private Hosted Zone
resource "aws_route53_zone" "private" {
  name = "volo.pk"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "jenkins.volo.pk"
  type    = "CNAME"
  ttl     = 60
  records = ["placeholder.us-east-1.elb.amazonaws.com"]

  lifecycle {
    ignore_changes = [records]
  }
}

resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "dev.volo.pk"
  type    = "CNAME"
  ttl     = 60
  records = ["placeholder.us-east-1.elb.amazonaws.com"]

  lifecycle {
    ignore_changes = [records]
  }
}

resource "aws_route53_record" "eks_endpoint" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "0477CBD65A8E579C72E8CF6690A088E8.gr7.us-east-1.eks.amazonaws.com"
  type    = "A"
  ttl     = 60
  records = ["32.192.120.190", "34.236.10.236"]
}

resource "local_file" "secret_provider" {
  content = templatefile("${path.root}/../../3-tier app/k8s/k8s/secret-provider.yaml", {
    app_irsa_role_arn = module.iam_irsa.app_irsa_role_arn
  })
  filename = "${path.root}/../../3-tier app/k8s/k8s/secret-provider-rendered.yaml"
}

resource "local_file" "mysql_service" {
  content = templatefile("${path.root}/../../3-tier app/k8s/k8s/mysql-deployment.yaml", {
    rds_endpoint = module.rds.rds_endpoint
  })
  filename = "${path.root}/../../3-tier app/k8s/k8s/mysql-service-rendered.yaml"
}

output "rds_endpoint"     { value = module.rds.rds_endpoint }
output "eks_cluster_name" { value = module.eks.cluster_name }
