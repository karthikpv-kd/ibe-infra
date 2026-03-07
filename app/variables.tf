variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

# ─── Database ───
variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB for RDS"
  default     = 20
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "tenant_service_db"
}

variable "db_username" {
  type        = string
  description = "Master username for the RDS instance"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password for the RDS instance"
}

# ─── ECS ───
variable "ecs_task_cpu" {
  type        = number
  description = "CPU units for ECS tasks"
  default     = 512
}

variable "ecs_task_memory" {
  type        = number
  description = "Memory in MiB for ECS tasks"
  default     = 1024
}

# ─── Bastion ───
variable "bastion_key_name" {
  type        = string
  description = "Name of the SSH key pair for the bastion host"
}

variable "bastion_ingress_cidr" {
  type        = string
  description = "CIDR block allowed to SSH into the bastion host"
  default     = "0.0.0.0/0"
}


