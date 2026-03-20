resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.name_prefix}-tenant-db-secret"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Name = "${var.name_prefix}-tenant-db-secret" })
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = 5432
    dbname   = var.db_name
  })
}
