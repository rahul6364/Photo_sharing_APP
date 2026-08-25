output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS database hostname"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS database port"
  value       = aws_db_instance.this.port
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "RDS subnet group name"
  value       = aws_db_subnet_group.this.name
}