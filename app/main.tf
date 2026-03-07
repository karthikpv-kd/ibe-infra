# ─── VPC ───
module "vpc" {
  source = "./modules/vpc"

  aws_region  = var.aws_region
  name_prefix = local.prefix
  tags        = local.global_tags
}

# ─── Security Groups ───
module "security" {
  source = "./modules/security"

  vpc_id               = module.vpc.vpc_id
  name_prefix          = local.prefix
  bastion_ingress_cidr = var.bastion_ingress_cidr

  tags = local.global_tags
}

# ─── ECR Repositories ───
module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.prefix
  tags        = local.global_tags
}

# ─── RDS PostgreSQL ───
module "rds" {
  source = "./modules/rds"

  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  name_prefix          = local.prefix

  tags = local.global_tags
}

# ─── Secrets Manager ───
module "secrets" {
  source = "./modules/secrets"

  db_username = var.db_username
  db_password = var.db_password
  db_host     = module.rds.rds_endpoint
  db_name     = var.db_name
  name_prefix = local.prefix

  tags = local.global_tags
}

# ─── Application Load Balancer ───
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security.alb_security_group_id
  name_prefix       = local.prefix

  tags = local.global_tags
}

# ─── ECS Fargate ───
module "ecs" {
  source = "./modules/ecs"

  vpc_id                      = module.vpc.vpc_id
  private_subnet_ids          = module.vpc.private_subnet_ids
  ecs_security_group_id       = module.security.ecs_security_group_id
  tenant_target_group_arn     = module.alb.tenant_target_group_arn
  room_search_target_group_arn = module.alb.room_search_target_group_arn
  tenant_ecr_repo_url         = module.ecr.tenant_service_repo_url
  room_search_ecr_repo_url    = module.ecr.room_search_service_repo_url
  secret_arn                  = module.secrets.secret_arn
  db_host                     = module.rds.rds_endpoint
  db_port                     = module.rds.rds_port
  db_name                     = var.db_name
  alb_dns_name                = module.alb.alb_dns_name
  aws_region                  = var.aws_region
  name_prefix                 = local.prefix
  cpu                         = var.ecs_task_cpu
  memory                      = var.ecs_task_memory

  tags = local.global_tags
}

# ─── Bastion Host ───
module "bastion" {
  source = "./modules/bastion"

  public_subnet_id  = module.vpc.public_subnet_ids[0]
  security_group_id = module.security.bastion_security_group_id
  key_name          = var.bastion_key_name
  secret_arn        = module.secrets.secret_arn
  name_prefix       = local.prefix

  tags = local.global_tags
}

# ─── CI/CD Pipelines ───
module "cicd" {
  source = "./modules/cicd"

  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
  ecr_repo_arns  = [module.ecr.tenant_service_repo_arn, module.ecr.room_search_service_repo_arn]
  name_prefix    = local.prefix

  tags = local.global_tags
}