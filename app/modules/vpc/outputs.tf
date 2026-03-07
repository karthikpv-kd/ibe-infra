output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = [
    module.subnets_az1.public_subnet_id,
    module.subnets_az2.public_subnet_id,
  ]
}

output "private_subnet_ids" {
  value = [
    module.subnets_az1.private_subnet_id,
    module.subnets_az2.private_subnet_id,
  ]
}

output "ecr_api_endpoint_id" {
  value = module.endpoints.ecr_api_endpoint_id
}

output "ecr_dkr_endpoint_id" {
  value = module.endpoints.ecr_dkr_endpoint_id
}

output "s3_endpoint_id" {
  value = module.endpoints.s3_endpoint_id
}

output "secretsmanager_endpoint_id" {
  value = module.endpoints.secretsmanager_endpoint_id
}

output "logs_endpoint_id" {
  value = module.endpoints.logs_endpoint_id
}
