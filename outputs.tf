output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "public_route_table_destination" {
  description = "Destination CIDR block for the public route table"
  value       = aws_route.public_internet_gateway.destination_cidr_block
}

output "kms_key_arn" {
  description = "ARN of the AWS managed KMS key for Secrets Manager"
  value       = data.aws_kms_key.secretsmanager.arn
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "rds_address" {
  description = "RDS database hostname"
  value       = module.rds.db_address
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.db_security_group_id
}
