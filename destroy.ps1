# ============================================================
# Proper Destroy Script — Run before terraform destroy
# Usage: .\destroy.ps1
# ============================================================

$REGION = "us-east-1"
$VPC_ID = "vpc-054ae7bf7fdbfb75b"

Write-Host "`n=== Step 1: Delete Kubernetes Ingress (ALBs) ===" -ForegroundColor Cyan
kubectl delete ingress --all -A --ignore-not-found

Write-Host "`n=== Step 2: Waiting for ALBs to delete (60s) ===" -ForegroundColor Cyan
Start-Sleep -Seconds 60

Write-Host "`n=== Step 3: Delete remaining ALBs ===" -ForegroundColor Cyan
$albs = aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[*].LoadBalancerArn" --output text
foreach ($alb in $albs -split "\t") {
    if ($alb) {
        Write-Host "Deleting ALB: $alb"
        aws elbv2 delete-load-balancer --load-balancer-arn $alb --region $REGION
    }
}

Write-Host "`n=== Step 4: Waiting for ENIs to delete (60s) ===" -ForegroundColor Cyan
Start-Sleep -Seconds 60

Write-Host "`n=== Step 5: Delete remaining Security Groups ===" -ForegroundColor Cyan
$sgs = aws ec2 describe-security-groups --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text
foreach ($sg in $sgs -split "\t") {
    if ($sg) {
        Write-Host "Deleting SG: $sg"
        aws ec2 delete-security-group --group-id $sg --region $REGION 2>$null
    }
}

Write-Host "`n=== Step 6: Delete Route53 extra records ===" -ForegroundColor Cyan
aws route53 change-resource-record-sets --hosted-zone-id Z088236313H5NGOJ1X4D4 --change-batch file://../delete-dns.json 2>$null

Write-Host "`n=== Step 7: Terraform Destroy ===" -ForegroundColor Cyan
cd terraform
terraform destroy -auto-approve

Write-Host "`n=== Done! ===" -ForegroundColor Green
