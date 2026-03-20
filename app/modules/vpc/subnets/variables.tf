variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to use for subnet names"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone to create subnets in"
  type        = string
}
