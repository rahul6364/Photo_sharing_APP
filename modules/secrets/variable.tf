variable "secret_name" {
  type        = string
  description = "Name of the database secret"
  default     = "photoshare/db/credentials"
}
variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt the secret"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}

variable "engine" {
  type        = string
  description = "Database engine"
  default     = "mysql"
}

variable "host" {
  type        = string
  description = "Database endpoint"
}

variable "port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_name" {
  type        = string
  description = "Database name"
}