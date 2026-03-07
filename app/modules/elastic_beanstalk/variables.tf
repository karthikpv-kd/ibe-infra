variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the ALB"
  type        = string
}

variable "app_private_subnet_id" {
  description = "Private subnet ID for Elastic Beanstalk instances"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "eb_security_group_id" {
  description = "Security group ID for Elastic Beanstalk instances"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint host"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
