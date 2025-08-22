output "certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}

output "fqdn_suffix" {
  value = var.fqdn_suffix
}
