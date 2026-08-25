data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}