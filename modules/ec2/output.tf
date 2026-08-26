output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Web server security group ID"
  value       = aws_security_group.this.id
}