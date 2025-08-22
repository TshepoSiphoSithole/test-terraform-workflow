# based on https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html

#
# create a private DNS namespace for the environment virtual private cloud
#
resource "aws_service_discovery_private_dns_namespace" "environment_svc_namespace" {
  name        = "${var.environment}.vpc.local"
  description = "Private DNS Namespace for ECS Services"
  vpc         = aws_vpc.env_vpc.id
}
