# create dns records for each domain
resource "aws_route53_record" "dns_record" {
  for_each        = {for idx, record in var.fqdn_records : idx => record}
  allow_overwrite = true
  name            = each.value.hostname
  records         = each.value.values
  ttl             = each.value.ttl
  type            = each.value.type
  zone_id         = var.zone_id
}

