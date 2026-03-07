variable "public_subnet_id" {
  description = "Public subnet ID for NAT gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to use for NAT gateway resources"
  type        = string
}
