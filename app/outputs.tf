output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

# REDIS DISABLED — uncomment when ElastiCache is re-enabled
# output "redis_endpoint" {
#   description = "ElastiCache Redis primary endpoint"
#   value       = module.elasticache.redis_primary_endpoint
# }

output "secret_arn" {
  value = module.secrets.secret_arn
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "tenant_ecr_repo_url" {
  value = module.ecr.tenant_service_repo_url
}

output "room_search_ecr_repo_url" {
  value = module.ecr.room_search_service_repo_url
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "tenant_codebuild_project_name" {
  value = module.cicd.tenant_codebuild_project_name
}

output "room_search_codebuild_project_name" {
  value = module.cicd.room_search_codebuild_project_name
}

# ─── VPC Endpoint IDs ───
output "ecr_api_endpoint_id" {
  description = "ID of the ECR API interface endpoint"
  value       = module.vpc.ecr_api_endpoint_id
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR interface endpoint"
  value       = module.vpc.ecr_dkr_endpoint_id
}

output "s3_endpoint_id" {
  description = "ID of the S3 gateway endpoint"
  value       = module.vpc.s3_endpoint_id
}

output "secretsmanager_endpoint_id" {
  description = "ID of the Secrets Manager interface endpoint"
  value       = module.vpc.secretsmanager_endpoint_id
}

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs interface endpoint"
  value       = module.vpc.logs_endpoint_id
}
