variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-3"
}

variable "state_bucket_name" {
  description = "S3 bucket for terraform state"
  type        = string
  default     = "ascend-ibe-terraform-state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for terraform state locking"
  type        = string
  default     = "ascend-terraform-locks"
}