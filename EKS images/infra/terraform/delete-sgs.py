import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client('ec2', region_name='us-east-1')
vpc_id = 'vpc-08411d67ed956e84d'

print(f"Finding security groups for {vpc_id}...")
sgs = ec2.describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}])['SecurityGroups']

sg_ids = [sg['GroupId'] for sg in sgs if sg['GroupName'] != 'default']

for sg_id in sg_ids:
    print(f"Removing rules from {sg_id}...")
    try:
        sg = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]
        if sg.get('IpPermissions'):
            ec2.revoke_security_group_ingress(GroupId=sg_id, IpPermissions=sg['IpPermissions'])
        if sg.get('IpPermissionsEgress'):
            ec2.revoke_security_group_egress(GroupId=sg_id, IpPermissions=sg['IpPermissionsEgress'])
    except Exception as e:
        print(f"Error removing rules for {sg_id}: {e}")

for sg_id in sg_ids:
    print(f"Deleting {sg_id}...")
    try:
        ec2.delete_security_group(GroupId=sg_id)
        print("Success!")
    except Exception as e:
        print(f"Error deleting {sg_id}: {e}")
