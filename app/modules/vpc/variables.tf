variable "name_prefix" {
  description = "Prefix to use for explicit resource names (e.g. ascend-ibe)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region (used for VPC endpoint service names)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_az1" {
  description = "CIDR block for the public subnet in AZ1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_az1" {
  description = "CIDR block for the private subnet in AZ1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_az1" {
  description = "First availability zone"
  type        = string
  default     = "ap-northeast-3a"
}

variable "public_subnet_cidr_az2" {
  description = "CIDR block for the public subnet in AZ2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_az2" {
  description = "CIDR block for the private subnet in AZ2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_az2" {
  description = "Second availability zone"
  type        = string
  default     = "ap-northeast-3b"
}