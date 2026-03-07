variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "tenant_target_group_arn" {
  description = "ALB target group ARN for tenant service"
  type        = string
}

variable "room_search_target_group_arn" {
  description = "ALB target group ARN for room search service"
  type        = string
}

variable "tenant_ecr_repo_url" {
  description = "ECR repository URL for tenant service"
  type        = string
}

variable "room_search_ecr_repo_url" {
  description = "ECR repository URL for room search service"
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

variable "db_port" {
  description = "RDS port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB for service-to-service communication"
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

variable "cpu" {
  description = "CPU units for ECS tasks"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memory in MiB for ECS tasks"
  type        = number
  default     = 1024
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
