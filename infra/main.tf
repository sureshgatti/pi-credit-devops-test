# Main entrypoint wires modules together

# ---- VPC ----
module "vpc" {
  source   = "./modules/vpc"
  env      = var.env
  vpc_cidr = var.vpc_cidr
}

# ---- ALB ----
module "alb" {
  source  = "./modules/alb"
  env     = var.env
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
}

# ---- ASG (App EC2 instances) ----
module "asg" {
  source           = "./modules/asg"
  env              = var.env
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.private_subnets
  alb_target_group = module.alb.target_group_arn
  ecr_image        = var.ecr_image
  key_name         = var.key_name
  ami_id           = var.ami_id
}

# ---- RDS (Postgres DB) ----
module "rds" {
  source  = "./modules/rds"
  env     = var.env
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
  app_sg  = module.asg.app_sg_id
}

# ---- EKS (Kubernetes) ----
module "eks" {
  source  = "./modules/eks"
  env     = var.env
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
}
