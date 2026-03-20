variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for SES and SQS endpoint construction"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Lambda will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue this Lambda will consume from"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the SQS queue (used in Lambda env var)"
  type        = string
}

variable "ses_sender_email" {
  description = "Verified SES email address to send from"
  type        = string
}

variable "ses_receiver_email" {
  description = "Verified SES recipient email address"
  type        = string
}

variable "ses_sender_email_arn" {
  description = "ARN of the verified SES identity (format: arn:aws:ses:REGION:ACCOUNT:identity/EMAIL)"
  type        = string
}

variable "ses_receiver_email_arn" {
  description = "ARN of the verified SES identity (format: arn:aws:ses:REGION:ACCOUNT:identity/EMAIL)"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment zip file"
  type        = string
  default     = "./lambda/email_sender.zip"
}

variable "lambda_handler" {
  description = "Lambda handler entrypoint"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "batch_size" {
  description = "Number of SQS messages to process per Lambda invocation"
  type        = number
  default     = 1
}

variable "ecs_lambda_security_group_id" {
  description = "Security group ID of ECS/Lambda resources that need SQS/SES VPC endpoint access"
  type        = string
}
