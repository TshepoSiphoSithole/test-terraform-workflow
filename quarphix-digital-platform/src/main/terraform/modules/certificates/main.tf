# create a wildcard certificate for the domain suffix
resource "aws_acm_certificate" "certificate" {
  domain_name               = "*.${var.fqdn_suffix}"
  validation_method         = "DNS"
  subject_alternative_names = [var.fqdn_suffix]

  tags = {
    Name        = "${var.team}-${var.environment}-${var.project}-cert"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create certificate validation dns records
resource "aws_route53_record" "dns_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

# validate wildcard certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_record : record.fqdn]
}
