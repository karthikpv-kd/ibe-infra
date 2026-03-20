variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to use for internet gateway name"
  type        = string
}
