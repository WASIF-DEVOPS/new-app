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

variable "server_cert_arn" {
  description = "ACM ARN for VPN server certificate"
  type        = string
}

variable "client_cert_arn" {
  description = "ACM ARN for VPN client certificate"
  type        = string
}
