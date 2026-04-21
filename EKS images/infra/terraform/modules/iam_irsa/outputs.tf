output "jenkins_irsa_role_arn"   { value = aws_iam_role.jenkins_irsa.arn }
output "app_irsa_role_arn"       { value = aws_iam_role.app_irsa.arn }
output "alb_controller_role_arn" { value = aws_iam_role.alb_controller.arn }
output "ebs_csi_role_arn"      { value = aws_iam_role.ebs_csi.arn }
