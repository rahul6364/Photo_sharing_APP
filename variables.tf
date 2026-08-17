variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones to use for subnets"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "project_name" {
  type        = string
  description = "Project name to be used for tagging resources"
  default     = "photo-sharing-app"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "photoshare-vpc"
}

variable "public_subnet_names" {
  type        = list(string)
  description = "Names of the public subnets"
  default     = ["Public Subnet 1", "Public Subnet 2"]
}

variable "private_subnet_names" {
  type        = list(string)
  description = "Names of the private subnets"
  default     = ["Private Subnet 1", "Private Subnet 2"]
}

variable "igw_name" {
  type        = string
  description = "Name of the Internet Gateway"
  default     = "photoshare-igw"
}

variable "nat_gateway_name" { 
  type        = string
  description = "Name of the NAT Gateway"
  default     = "photoshare-nat-gw"
}

variable "public_route_table_name" {
  type        = string
  description = "Name of the Public Route Table"
  default     = "public-rt"
}


