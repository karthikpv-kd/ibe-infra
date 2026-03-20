variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "message_retention_seconds" {
  description = "How long SQS retains messages in seconds"
  type        = number
  default     = 86400
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the primary queue"
  type        = number
  default     = 60
}

variable "max_receive_count" {
  description = "Number of times a message is received before moving to DLQ"
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "How long DLQ retains messages for inspection"
  type        = number
  default     = 1209600
}
