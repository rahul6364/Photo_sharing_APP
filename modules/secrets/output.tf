output "secret_arn" {
  description = "ARN of the PhotoShare database secret"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Name of the PhotoShare database secret"
  value       = aws_secretsmanager_secret.this.name
}