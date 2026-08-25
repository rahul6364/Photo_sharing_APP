variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS database will be deployed"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR allowed to access the database"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the RDS subnet group"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password for the RDS database"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
  default     = "photoshare"
}

variable "db_username" {
  type        = string
  description = "Master username"
  default     = "admin"
}

variable "db_identifier" {
  type        = string
  description = "RDS instance identifier"
  default     = "photoshare-db"
}