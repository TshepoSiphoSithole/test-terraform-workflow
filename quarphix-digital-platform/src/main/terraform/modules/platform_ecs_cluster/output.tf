output "ecs_cluster" {
  value = {
    id                       = aws_ecs_cluster.platform_cluster.id,
    name                     = aws_ecs_cluster.platform_cluster.name
    arn                      = aws_ecs_cluster.platform_cluster.arn
    container_security_group = aws_security_group.container_sg
  }
}
