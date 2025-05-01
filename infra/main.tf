module "core" {
  source     = "./modules/core"
  app_name   = "local.app_name"
  aws_region = var.aws_region
}

module "actions" {
  source                = "./modules/actions"
  app_name              = local.app_name
  aws_region            = var.aws_region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  vpc_id                      = module.core.vpc_id
  public_subnets              = module.core.public_subnets
  core_sg_id                  = module.core.core_sg_id
  ecs_desired_count           = 1
  ecs_cluster_id              = module.core.ecs_cluster_id
  ecs_task_execution_role_arn = module.core.ecs_task_execution_role_arn
  route53_zone_id             = var.route53_zone_id
  domain_name                 = var.domain_name
  acm_certificate_arn         = var.acm_certificate_arn
}

module "bot" {
  source                = "./modules/bot"
  app_name              = local.app_name
  aws_region            = var.aws_region
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  vpc_id                      = module.core.vpc_id
  public_subnets              = module.core.public_subnets
  core_sg_id                  = module.core.core_sg_id
  ecs_desired_count           = 1
  ecs_cluster_id              = module.core.ecs_cluster_id
  ecs_task_execution_role_arn = module.core.ecs_task_execution_role_arn
  route53_zone_id             = var.route53_zone_id
  domain_name                 = var.domain_name
  acm_certificate_arn         = var.acm_certificate_arn
}

