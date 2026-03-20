variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ElastiCache"
  type        = list(string)
}

variable "redis_security_group_id" {
  description = "Security group ID for the Redis cluster"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
