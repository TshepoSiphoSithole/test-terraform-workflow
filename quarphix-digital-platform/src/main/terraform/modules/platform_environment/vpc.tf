data "aws_availability_zones" "available" {
  state = "available"
}

# create vpc
resource "aws_vpc" "env_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags                 = local.compulsory_tags
  lifecycle {
    prevent_destroy = false
  }
}

#
# create private subnet
#
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr_list)
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = element(var.private_subnet_cidr_list, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge(local.compulsory_tags, {
    "Name" = "${var.team}-${var.environment}-${var.project}-private-${element(data.aws_availability_zones.available.names, count.index)}"
  })
}

#
# create public subnet
#
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidr_list)
  vpc_id            = aws_vpc.env_vpc.id
  cidr_block        = element(var.public_subnet_cidr_list, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge(local.compulsory_tags, {
    "Name" = "${var.team}-${var.environment}-${var.project}-public-${element(data.aws_availability_zones.available.names, count.index)}"
  })
}

#
# setup internet gateway
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
#
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.env_vpc.id
  tags   = merge(local.compulsory_tags, {
    "Name" = "${var.team}-${var.environment}-${var.project}-internet-gateway"
  })
}

#
#  Public Subnet Route Table
#
resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = aws_vpc.env_vpc.id
  tags   = merge(local.compulsory_tags, {
    "Name" = "${var.team}-${var.environment}-${var.project}-public-subnet-route-table"
  })
}

#
# Associate public subnet to a routing table
#
resource "aws_route_table_association" "public-subnet-route-table-association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets, count.index).id
  route_table_id = aws_route_table.public-subnet-route-table.id
  depends_on     = [aws_subnet.public_subnets]
}

#
# allow resources in public subnet to connect to all external destinations
#
resource "aws_route" "public-subnet-route" {
  route_table_id         = aws_route_table.public-subnet-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
