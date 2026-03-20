variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "private_subnet_id_az1" {
  description = "Private subnet ID for AZ1"
  type        = string
}

variable "private_subnet_id_az2" {
  description = "Private subnet ID for AZ2"
  type        = string
}

variable "igw_id" {
  description = "Internet gateway ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to use for route table names"
  type        = string
}
