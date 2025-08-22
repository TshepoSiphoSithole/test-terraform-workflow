output "vpc_id" {
  value = module.flex_environment.vpc_id
}

output "vpc" {
  value = {
    id                          = module.flex_environment.vpc_id
    cidr_block                  = module.flex_environment.vpc_cidr
    private_subnets             = module.flex_environment.private_subnets.ids
    public_subnets              = module.flex_environment.public_subnets.ids
    internet_gateway            = module.flex_environment.internet_gateway
    public_subnet_routing_table = module.flex_environment.public_subnet_routing_table
  }
}

output "tenants" {
  value = module.flex_environment.tenants
}

output "private_subnets" {
  value = module.flex_environment.private_subnets.ids
}

output "public_subnets" {
  value = module.flex_environment.public_subnets.ids
}

output "internet_gateway" {
  value = module.flex_environment.internet_gateway
}

output "alb" {
  value = module.flex_environment.alb
}

output "alb_https_listener" {
  value = module.flex_environment.alb_https_listener
}

output "alb_http_listener" {
  value = module.flex_environment.alb_http_listener
}

