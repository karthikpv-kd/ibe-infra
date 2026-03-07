variable "vpc_id" {
  description = "VPC ID to attach endpoints to"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC (used to scope endpoint SG ingress)"
  type        = string
}

variable "aws_region" {
  description = "AWS region (used to build service names, e.g. com.amazonaws.ap-northeast-3.ecr.api)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where interface endpoint ENIs are placed"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Private route table IDs for the S3 gateway endpoint route entries"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all endpoint resources"
  type        = map(string)
  default     = {}
}
