variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "dev-eks-cluster"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "dev-vpc"
}

variable "db_password" {
  description = "MySQL DB password"
  type        = string
  sensitive   = true
}

