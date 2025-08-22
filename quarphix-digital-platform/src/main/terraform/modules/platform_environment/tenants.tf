#
# register tenant cluster
#
module "tenant_ecs_cluster" {
  for_each              = local.tenant_map
  source                = "../platform_ecs_cluster"
  cluster_name          = "${var.environment}-${each.value.name}"
  environment           = var.environment
  project               = var.project
  team                  = var.team
  alb_security_group_id = aws_security_group.alb_security_group.id
  vpc_id                = aws_vpc.env_vpc.id
}

module "tenant_dns" {
  for_each      = local.tenant_map
  source        = "../tenant_dns"
  environment   = var.environment
  fqdn_suffixes = [
    for fqdn in var.fqdns : ({
      fqdn    = "${var.environment}.${fqdn.fqdn}"
      zone_id = aws_route53_zone.env_sub_domain[fqdn.fqdn].zone_id
    })
  ]
  project = var.project
  team    = var.team
  tenant  = {
    name = each.value.name
  }
  load_balancer = {
    arn          = aws_lb.alb.id
    dns_name     = aws_lb.alb.dns_name
    zone_id      = aws_lb.alb.zone_id
    lb_listener = {
      arn = aws_lb_listener.alb_https_listener[0].arn
    }
    target_group = {
      arn = aws_lb_target_group.alb_target_group.arn
    }
  }
  vpc_id             = aws_vpc.env_vpc.id
}
