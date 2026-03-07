# ─── VPC ───
module "vpc" {
  source      = "./vpc"
  vpc_cidr    = var.vpc_cidr
  name_prefix = var.name_prefix
  tags        = var.tags
}

# ─── Subnets AZ1 ───
module "subnets_az1" {
  source              = "./subnets"
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = var.public_subnet_cidr_az1
  private_subnet_cidr = var.private_subnet_cidr_az1
  availability_zone   = var.availability_zone_az1
  name_prefix         = "${var.name_prefix}-az1"
  tags                = var.tags
}

# ─── Subnets AZ2 (needed for RDS db_subnet_group) ───
module "subnets_az2" {
  source              = "./subnets"
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = var.public_subnet_cidr_az2
  private_subnet_cidr = var.private_subnet_cidr_az2
  availability_zone   = var.availability_zone_az2
  name_prefix         = "${var.name_prefix}-az2"
  tags                = var.tags
}

# ─── Internet Gateway ───
module "internet_gateway" {
  source      = "./internet-gateway"
  vpc_id      = module.vpc.vpc_id
  name_prefix = var.name_prefix
  tags        = var.tags
}

# ─── Route Tables ───
# Private route table has no default internet route — internet traffic is not
# needed because AWS services are reached exclusively through VPC endpoints.
module "route_tables" {
  source                = "./route-tables"
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.subnets_az1.public_subnet_id
  private_subnet_id_az1 = module.subnets_az1.private_subnet_id
  private_subnet_id_az2 = module.subnets_az2.private_subnet_id
  igw_id                = module.internet_gateway.igw_id
  name_prefix           = var.name_prefix
  tags                  = var.tags
}

# ─── VPC Endpoints ───
# Interface endpoints (ECR API/DKR, Secrets Manager, CloudWatch Logs) and an
# S3 gateway endpoint allow ECS tasks in private subnets to reach AWS services
# without a NAT gateway or internet access.
module "endpoints" {
  source                  = "./endpoints"
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = var.vpc_cidr
  aws_region              = var.aws_region
  private_subnet_ids      = [module.subnets_az1.private_subnet_id, module.subnets_az2.private_subnet_id]
  private_route_table_ids = [module.route_tables.private_rt_id]
  name_prefix             = var.name_prefix
  tags                    = var.tags
}