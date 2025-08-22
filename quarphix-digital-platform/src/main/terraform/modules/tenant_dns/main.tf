#
# create a zone for the environment sub domain
#
resource "aws_route53_zone" "tenant_env_domain_zone" {
  for_each = local.fqdn_zone_id_map
  name     = each.key
  tags     = merge(local.compulsory_tags, {
    "Name" = "${var.team}-${var.tenant.name}-${var.environment}-${var.project}-environment-zone"
  })
}

#
# register an NS record for the environment subdomain in the parent zone
#
resource "aws_route53_record" "tenant_env_sub_domain_ns_record" {
  for_each = local.fqdn_zone_id_map
  name     = each.key
  zone_id  = each.value
  type     = "NS"
  ttl      = "30"
  records  = aws_route53_zone.tenant_env_domain_zone[each.key].name_servers
}

#
# create certificate for the tenant environment sub domain
#
module "certificates" {
  for_each    = local.fqdn_zone_id_map
  source      = "../certificates"
  team        = var.team
  environment = var.environment
  project     = var.project
  fqdn_suffix = each.key
  zone_id     = aws_route53_zone.tenant_env_domain_zone[each.key].zone_id
}

#
# create a private DNS namespace for the environment virtual private cloud
#
resource "aws_service_discovery_private_dns_namespace" "tenant_env_svc_namespace" {
  name        = "${lower(var.tenant.name)}.${var.environment}.vpc.local"
  description = "Private DNS Namespace for ECS Services"
  vpc         = var.vpc_id
}

#
# Associate certificates to the load balancer https listener
#
resource "aws_alb_listener_certificate" "listener_certificate" {
  for_each        = local.fqdn_zone_id_map
  certificate_arn = module.certificates[each.key].certificate_arn
  listener_arn    = var.load_balancer.lb_listener.arn
}


#
# Configure DNS Route to Load Balancer
# resolve all subdomains in public dns zones to the application load balancer dns name
#
resource "aws_route53_record" "catch_all" {
  for_each = local.fqdn_zone_id_map
  zone_id  = aws_route53_zone.tenant_env_domain_zone[each.key].zone_id
  name     = "*"
  type     = "A"

  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = true
  }
}
