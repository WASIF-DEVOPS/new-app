output "cluster_role_arn"      { value = aws_iam_role.eks_cluster.arn }
output "node_role_arn"         { value = aws_iam_role.eks_node.arn }
output "jenkins_irsa_role_arn" { value = aws_iam_role.jenkins_irsa.arn }
output "alb_controller_role_arn" { value = aws_iam_role.alb_controller.arn }
