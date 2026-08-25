output "alb_arn" {
  value = aws_alb.this.arn
}

output "alb_dns_name" {
  value = aws_alb.this.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.this.id
}

output "target_group_arn" {
  value = aws_alb_target_group.this.arn
}

output "target_group_name" {
  value = aws_alb_target_group.this.name
}