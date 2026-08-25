variable "function_name" {
  type    = string
  default = "photoshare-metadata-extractor"
}

variable "role_arn" {
  type        = string
  description = "IAM role ARN for Lambda"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket containing uploaded photos"
}

variable "alb_dns_name" {
  type        = string
  description = "Application Load Balancer DNS name"
}

variable "source_file" {
  type        = string
  description = "Path to Lambda source code"
  default     = "lambda_handler.py"
}
variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket triggering Lambda"
}