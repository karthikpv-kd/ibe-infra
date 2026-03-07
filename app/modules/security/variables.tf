variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "bastion_ingress_cidr" {
  description = "CIDR block allowed to SSH into the bastion host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
