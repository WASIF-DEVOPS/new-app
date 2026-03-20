variable "aws_region"      { default = "us-east-1" }
variable "cluster_name"    { default = "dev-eks-cluster" }
variable "vpc_name"        { default = "dev-vpc" }
variable "server_cert_arn" { type = string }
variable "client_cert_arn" { type = string }
