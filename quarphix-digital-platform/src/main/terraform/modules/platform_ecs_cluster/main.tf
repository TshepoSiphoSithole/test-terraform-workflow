#
# Responsible for creating an ECS Cluster and it's configuration
#

# cloudwatch logs
resource "aws_cloudwatch_log_group" "platform_cluster_log_group" {
  name = "${var.environment}-${var.cluster_name}-cloudwatch-log-group"
  retention_in_days = 7
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
  tags = merge(local.compulsory_tags, {
    "Name" = "${var.environment}-${var.cluster_name}-cloudwatch-log-group"
  })
}

# create ecs cluster
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html
resource "aws_ecs_cluster" "platform_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      //TODO review log encryption
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.platform_cluster_log_group.name
      }
    }
  }
}

# cluster capacity providers
# FARGATE is the chosen capacity provider
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.platform_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

#
# Security group associated with the containers running in the VPC.
#
resource "aws_security_group" "container_sg" {
  name        = "${var.environment}-${var.cluster_name}-ecs-container-sg"
  description = "${var.environment} ECS Container security group for ${var.cluster_name}"
  vpc_id      = var.vpc_id
  tags = merge(local.compulsory_tags, {
    Name : "${var.environment}-${var.cluster_name}-ecs-container-sg"
  })
}


#
# Allow the ALB traffic to the container security group
#
resource "aws_security_group_rule" "container_allow_alb_rule" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.alb_security_group_id
  security_group_id        = aws_security_group.container_sg.id
}

#
# allow all traffic out of the container
#
resource "aws_security_group_rule" "container_egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.container_sg.id
}

#
# Allow the containers in the same security group regardless of subnet to communicate
#
resource "aws_security_group_rule" "container_sg_allow_rule" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.container_sg.id
  security_group_id        = aws_security_group.container_sg.id
}

#
# Allow the containers in the security group to communicate to NFS inbound and outbound
#
resource "aws_security_group_rule" "container_sg_allow_nfs_rule" {
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.container_sg.id
}

resource "aws_security_group_rule" "nfs-in" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.container_sg.id
}