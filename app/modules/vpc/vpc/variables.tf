variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VPC"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to use for nested vpc resource names"
  type        = string
}
