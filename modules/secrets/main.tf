resource "aws_secretsmanager_secret" "this" {
  name        = var.secret_name
  description = "Database credentials for PhotoSharing App"

  kms_key_id = var.kms_key_arn
}
resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(
    {
      username = var.db_username
      password = var.db_password
      engine   = var.engine
      host     = var.host
      port     = 3306
      dbname   = var.db_name

    }
  )
}