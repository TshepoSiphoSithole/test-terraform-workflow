output "vpc_id" {
  value = module.prod_environment.vpc_id
}

output "vpc" {
  value = {
    id                          = module.prod_environment.vpc_id
    cidr_block                  = module.prod_environment.vpc_cidr
    private_subnets             = module.prod_environment.private_subnets.ids
    public_subnets              = module.prod_environment.public_subnets.ids
    internet_gateway            = module.prod_environment.internet_gateway
    public_subnet_routing_table = module.prod_environment.public_subnet_routing_table
  }
}

output "tenants" {
  value = module.prod_environment.tenants
}

output "private_subnets" {
  value = module.prod_environment.private_subnets.ids
}

output "public_subnets" {
  value = module.prod_environment.public_subnets.ids
}

output "internet_gateway" {
  value = module.prod_environment.internet_gateway
}

output "alb" {
  value = module.prod_environment.alb
}

output "alb_https_listener" {
  value = module.prod_environment.alb_https_listener
}

output "alb_http_listener" {
  value = module.prod_environment.alb_http_listener
}

