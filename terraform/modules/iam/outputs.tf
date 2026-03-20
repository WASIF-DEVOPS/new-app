output "cluster_role_arn"      { value = aws_iam_role.eks_cluster.arn }
output "node_role_arn"         { value = aws_iam_role.eks_node.arn }
output "jenkins_access_key_id" { value = aws_iam_access_key.jenkins.id }
output "jenkins_secret_key" {
  value     = aws_iam_access_key.jenkins.secret
  sensitive = true
}
