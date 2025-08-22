#
# Responsible for the creation of the Application Load Balancer
#

data "aws_caller_identity" "current" {}

#
# Create S3 Bucket to Store Access Logs for the application load balancer
#
resource "aws_s3_bucket" "alb_access_logs" {
  bucket = lower("${var.environment}-qdp-alb-access-logs")
  tags   = merge(local.compulsory_tags, {
    Name : "${var.project}-${var.environment}-qdp-alb-access-logs"
  })
}

#
# encrypt alb access logs
#
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.alb_access_logs.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# bucket policy for the alb access logs
#
resource "aws_s3_bucket_policy" "alb_access_logs" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "AWSConsole-AccessLogs-Policy-1541756780992",
    "Statement": [
        {
            "Sid": "AWSConsoleStmt-1541756780992",
            "Effect": "Allow",
            "Principal": {
                "AWS": "156460612806"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.alb_access_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.alb_access_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.alb_access_logs.arn}"
        }
    ]
}
POLICY
}

#
# create application load balancer security group
#
resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-ecs-alb"
  description = "${var.environment} security group"
  vpc_id      = aws_vpc.env_vpc.id
  tags        = merge(local.compulsory_tags, {
    Name : "${var.project}-${var.environment}-ecs-alb-sg"
  })
}

#
# allow traffic to the application load balancer security group on port 80
#
resource "aws_security_group_rule" "alb_ingress_allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_security_group.id
}

#
# allow traffic to the application load balancer security group on port 443
#
resource "aws_security_group_rule" "alb_ingress_allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_security_group.id
}

#
# allow all traffic out from the application load balancer security group
#
resource "aws_security_group_rule" "alb_egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_security_group.id
}

#
# create application load balancer
#
resource "aws_lb" "alb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = aws_subnet.public_subnets.*.id
  idle_timeout       = 120
  enable_deletion_protection = true
  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.alb_access_logs.bucket
  }

  tags = merge(local.compulsory_tags, {
    Name : "${var.project}-${var.environment}-alb"
  })
}

#
# Application Load balancer target group
#
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project}-${var.environment}-alb-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.env_vpc.id
}

#
# add http listener configuration to redirect to https 443
#
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#
# https listener configuration on the application load balancer to forward
# traffic to the node target group
#
resource "aws_lb_listener" "alb_https_listener" {
  count             = length(local.fqdn_suffixes) > 0 ? 1 : 0
  #  for_each          = toset(local.fqdn_suffixes)
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  # use the first element in certs as the default
  certificate_arn   = module.certificates[local.fqdn_suffixes[0]].certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

#
# Associate certificates to the load balancer https listener
#
resource "aws_alb_listener_certificate" "listener_certificate" {
  for_each        = toset([for idx, suffix in local.fqdn_suffixes : suffix if idx != 0])
  # skip the first element because it's used as default
  certificate_arn = each.key
  listener_arn    = aws_lb_listener.alb_https_listener[0].arn
}

#
# Configure DNS Route to Load Balancer
# resolve all subdomains in public dns zones to the application load balancer dns name
#
resource "aws_route53_record" "catch_all" {
  for_each = toset(local.fqdn_suffixes)
  zone_id  = aws_route53_zone.env_sub_domain[each.key].zone_id
  name     = "*"
  type     = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
