locals {
  fqdn_suffixes    = [for k in var.fqdns : k.fqdn]
  fqdn_records_map = { for fqdn in var.fqdns : fqdn.fqdn => fqdn.records }
  fqdn_zone_id_map = { for fqdn in var.fqdns : fqdn.fqdn => fqdn.zone_id }
}

#
# register dns records for the given fully qualified domain names
#
module "dns" {
  for_each     = toset(local.fqdn_suffixes)
  source       = "../dns_records"
  team         = var.team
  environment  = var.environment
  project      = var.project
  zone_id      = lookup(local.fqdn_zone_id_map, each.key, "")
  fqdn_suffix  = each.key
  fqdn_records = lookup(local.fqdn_records_map, each.key, [])
}

#
# the environment subdomain takes the form of flex.qdp.com or prod.qdp.com
#

#
# create a zone for the environment sub domain
#
resource "aws_route53_zone" "env_sub_domain" {
  for_each = toset(local.fqdn_suffixes)
  name     = "${var.environment}.${each.key}"
  tags = merge(local.compulsory_tags, {
    "Name" = "${var.team}-${var.environment}-${var.project}-environment-zone"
  })
}

#
# register an NS record for the environment subdomain in the parent zone
#
resource "aws_route53_record" "env_sub_domain_ns_record" {
  for_each = toset(local.fqdn_suffixes)
  zone_id  = lookup(local.fqdn_zone_id_map, each.key, "")
  name     = "${var.environment}.${each.key}"
  type     = "NS"
  ttl      = "30"
  records  = aws_route53_zone.env_sub_domain[each.key].name_servers

}

#
# create certificate for the environment sub domain
#
module "certificates" {
  for_each    = toset(local.fqdn_suffixes)
  source      = "../certificates"
  team        = var.team
  environment = var.environment
  project     = var.project
  fqdn_suffix = "${var.environment}.${each.key}"
  zone_id     = aws_route53_zone.env_sub_domain[each.key].zone_id
}
