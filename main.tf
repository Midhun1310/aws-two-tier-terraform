data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  azs         = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
}

module "security_groups" {
  source = "./modules/security-groups"

  name_prefix     = local.name_prefix
  vpc_id          = module.vpc.vpc_id
  cloudfront_only = var.enable_cdn
}

module "rds" {
  source = "./modules/rds"

  name_prefix           = local.name_prefix
  private_subnet_ids    = module.vpc.private_subnet_ids
  db_sg_id              = module.security_groups.db_sg_id
  db_name               = var.db_name
  db_username           = var.db_username
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  engine_version        = var.db_engine_version
  multi_az              = var.db_multi_az
  deletion_protection   = var.db_deletion_protection
  skip_final_snapshot   = var.db_skip_final_snapshot
  backup_retention_days = var.db_backup_retention_period
}

module "alb" {
  source = "./modules/alb"

  name_prefix           = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_sg_id             = module.security_groups.alb_sg_id
  certificate_arn       = var.alb_certificate_arn
  deletion_protection   = var.alb_deletion_protection
}

module "iam" {
  source = "./modules/iam"

  name_prefix   = local.name_prefix
  db_secret_arn = module.rds.db_secret_arn
}

module "compute" {
  source = "./modules/compute"

  name_prefix           = local.name_prefix
  instance_type         = var.instance_type
  instance_profile_name = module.iam.instance_profile_name
  web_sg_id             = module.security_groups.web_sg_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  asg_min_size          = var.asg_min_size
  asg_max_size          = var.asg_max_size
  asg_desired_capacity  = var.asg_desired_capacity
}

module "cdn" {
  source = "./modules/cdn"
  count  = var.enable_cdn ? 1 : 0

  providers = {
    aws           = aws
    aws.ap_south_1 = aws.ap_south_1
  }

  name_prefix  = local.name_prefix
  domain_name  = var.domain_name
  alb_dns_name = module.alb.alb_dns_name
}
