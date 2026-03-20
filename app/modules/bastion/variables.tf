variable "public_subnet_id" {
  description = "Public subnet ID for the bastion host"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret the bastion is allowed to read"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
