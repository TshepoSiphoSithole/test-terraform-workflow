output "vpc_id" {
  value = aws_vpc.env_vpc.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "private_subnets" {
  value = {
    ids   = aws_subnet.private_subnets.*.id
    cidrs = var.private_subnet_cidr_list
  }
}

output "public_subnets" {
  value = {
    ids   = aws_subnet.public_subnets.*.id
    cidrs = var.public_subnet_cidr_list
  }
}

output "internet_gateway" {
  value = aws_internet_gateway.ig
}

output "name" {
  value = {
    name = var.environment
  }
}

output "service_discovery_private_dns_namespace" {
  value = {
    id  = aws_service_discovery_private_dns_namespace.environment_svc_namespace.id,
    arn = aws_service_discovery_private_dns_namespace.environment_svc_namespace.arn
  }
}

output "alb_security_group" {
  value = aws_security_group.alb_security_group
}

output "ecs_clusters" {
  value = {for tenant in var.tenants : tenant.name => module.tenant_ecs_cluster[tenant.name].ecs_cluster}
}

output "public_subnet_routing_table" {
  value = aws_route_table.public-subnet-route-table
}

output "tenants" {
  value = {
    for tenant in var.tenants : tenant.name => {
      ecs_cluster                 = module.tenant_ecs_cluster[tenant.name].ecs_cluster
      domain_zone                 = module.tenant_dns[tenant.name].zone
      certificates                = module.tenant_dns[tenant.name].certificates
      service_discovery_namespace = module.tenant_dns[tenant.name].service_discovery_namespace
      fqdns                       = module.tenant_dns[tenant.name].fqdns
    }
  }
}

output "alb" {
  value = aws_lb.alb
}

output "alb_https_listener" {
  value = aws_lb_listener.alb_https_listener
}

output "alb_http_listener" {
  value = aws_lb_listener.alb_http_listener
}

