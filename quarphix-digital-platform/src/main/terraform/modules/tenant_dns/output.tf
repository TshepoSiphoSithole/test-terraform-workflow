output "zone" {
  value = aws_route53_zone.tenant_env_domain_zone
}

output "ns_record" {
  value = aws_route53_record.tenant_env_sub_domain_ns_record
}

output "certificates" {
  value = {
    for cert in module.certificates : cert.fqdn_suffix => cert.certificate_arn
  }
}

output "service_discovery_namespace" {
  value = aws_service_discovery_private_dns_namespace.tenant_env_svc_namespace
}

output "fqdns" {
  value = [for k, v in local.fqdn_zone_id_map : k]
}