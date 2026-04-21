resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = "1.31"

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }
}

# OIDC Provider for IRSA
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_security_group_rule" "eks_vpn_access" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.1.0.0/22", "10.0.0.0/16"]
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description       = "Allow kubectl from VPN clients and VPC"
}

resource "null_resource" "cleanup_ingress" {
  triggers = {
    cluster_name = aws_eks_cluster.main.name
  }

  provisioner "local-exec" {
    when       = destroy
    interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
      kubectl delete ingress --all -A --ignore-not-found 2>$null
      helm uninstall prometheus -n monitoring --ignore-not-found 2>$null
      helm uninstall grafana -n monitoring --ignore-not-found 2>$null
      kubectl delete namespace monitoring --ignore-not-found 2>$null
      kubectl delete namespace app --ignore-not-found 2>$null
      kubectl delete namespace jenkins --ignore-not-found 2>$null
      aws logs delete-log-group --log-group-name /aws/eks/${self.triggers.cluster_name}/cluster --region us-east-1 2>$null
      Start-Sleep -Seconds 60
      exit 0
    EOT
  }

  depends_on = [aws_eks_cluster.main]
}

# Node Group: Jenkins + App workloads
resource "aws_eks_node_group" "jenkins_app" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "jenkins-app-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  labels = { role = "jenkins-app" }
}

# Node Group: Jenkins Agents (CI/CD jobs)
resource "aws_eks_node_group" "jenkins_agents" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "jenkins-agents-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3 
  }

  labels = { role = "jenkins-agent" }
}
