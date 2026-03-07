variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "RDS endpoint host"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
