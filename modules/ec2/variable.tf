variable "vpc_id" {
  type = string
}
variable "alb_security_group_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "target_group_arn" {
  type        = string
  description = "Target group ARN"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile for EC2"
}

variable "s3_bucket_name" {
  type        = string
  description = "PhotoShare S3 bucket"
}
variable "secret_name" {
  type        = string
  description = "Secrets Manager database secret"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
  default     = null
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_name" {
  type    = string
  default = "photoshare-web"
}