module "secrets" {
  source = "./modules/secrets"

  secret_name = "photoshare/db/credentials"
  kms_key_arn = data.aws_kms_key.secretsmanager.arn
  db_username = var.db_username
  db_password = var.db_password
  engine      = "mysql"
  host        = module.rds.db_address
  port        = 3306
  db_name     = var.db_name
}