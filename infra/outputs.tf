output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "alb_dns" {
  value = module.alb.alb_dns
}

output "alb_target_group_arn" {
  value = module.alb.target_group_arn
}

output "asg_name" {
  value = module.asg.asg_name
}

output "app_sg_id" {
  value = module.asg.app_sg_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
