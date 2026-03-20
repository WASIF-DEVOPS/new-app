resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
}

# Node Group: Jenkins + App workloads
resource "aws_eks_node_group" "jenkins_app" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "jenkins-app-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  labels = { role = "jenkins-app" }
}

# Node Group: Jenkins Agents (CI/CD jobs)
resource "aws_eks_node_group" "jenkins_agents" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "jenkins-agents-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 6
  }

  labels = { role = "jenkins-agent" }
}
