resource "aws_secretsmanager_secret" "db" {
  name                    = "dev/three-tier-app/db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    DB_USER     = "appuser"
    DB_PASSWORD = var.db_password
    DB_HOST     = var.rds_endpoint
    DB_NAME     = "appdb"
  })
}
