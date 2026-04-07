resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/vpn/dev-team"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "connections"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}

resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "Dev Team VPN"
  server_certificate_arn = var.server_cert_arn
  client_cidr_block      = "172.16.0.0/22"
  split_tunnel           = true
  dns_servers            = ["10.0.0.2"]
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_cert_arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }
}

resource "aws_ec2_client_vpn_network_association" "private_1a" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = var.private_subnet_id_1a
}

resource "aws_ec2_client_vpn_network_association" "private_1b" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = var.private_subnet_id_1b
}

resource "aws_ec2_client_vpn_authorization_rule" "all" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = "10.0.0.0/16"
  authorize_all_groups   = true
}
