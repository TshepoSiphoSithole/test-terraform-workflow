# Wed Jan  8 10:07:47 SAST 2025
#
# create github runner security group
#
resource "aws_security_group" "github_runner_security_group" {
  name        = "${var.environment}-github-runner-sg"
  description = "GitHub Runner security group in the ${var.environment} environment"
  vpc_id      = module.flex_environment.vpc_id
  tags = merge(local.compulsory_tags, {
    Name : "${var.project}-${var.environment}-github-runner-sg"
  })
  provider = aws.digital_platform

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All connection to all destinations"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a secret for the runner access token
resource "aws_secretsmanager_secret" "github_runner_access_token" {
  name     = "github_runner_access_token"
  provider = aws.digital_platform
}

data "aws_secretsmanager_secret_version" "github_runner_secret_latest" {
  secret_id = aws_secretsmanager_secret.github_runner_access_token.id
  provider  = aws.digital_platform
}

resource "aws_key_pair" "github_runner" {
  key_name   = "github_runner"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6X6rth+MUxVr5dYvc/y5RVNDkekCI+FIwDYGHjwgbFLaWQsQhUzAAivyQGCw1bHxVOkOf6Gn3pK3wZ7M0RMmHKD51PEabZxi7YJyiZQqNIifJ6q+llpEN6H27qZ3NqQf7phDcEyLFCcF+Ize5Kaqnh5C0F9PXBMsMWx/w4njvmisoHS1UGJoMm7Ugi0gCV+Jyz2aBPkNtUdFyKQtQYF4Vn+BGVhnoFnx+aBnGqOxpkYFNhHM22+p0heWsWkEbeOzRg/hw6qmi2nWyNKkjE40rokOkyR3jCAy/kHq51rgNojm1az1R7I+MWyQY8MGL1g46H5Q352dBQMuNIVungDIClldBYKTyNqLmIbLMyEcQw+UCHbrA2KXHQp1rzYKgUXcxF/MdKdNE0ueKL3LWYZMhjdbU+uJ6LX6zTyVCaez+lXBUeJ0Jqfx95EmKFxSJYJhHln2xTPeQxOS9uC9EHT8HEPHyuwiiB/F19gVXWv1fg1MJQIlk/7yRz+Bgw8AzW3JPaL9dCFClpe7dIAq0bhDIwxNvGmPLlotaxdFXeGDy9CG+yEQojyaJWbeC0yj0V1XuVG608d4+7FPS4Kd/lEg1wXCsUYJo2n6Jfu2kgvvzJtUZ7ur+eqJFZfvBs5Ipih0QhwZYO2pq6nzS7jFk+T7SE4qZ2KnoyduQd0LoRGLr8w== github_runner"
  provider   = aws.digital_platform
}

resource "aws_launch_template" "github_runner" {
  name                                 = "github_runner_launch_template"
  image_id                             = "ami-00f117fe174f83c56"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t4g.large"
  user_data = base64encode(templatefile("${path.module}/github_runner_configurer.sh", {
    github_token = data.aws_secretsmanager_secret_version.github_runner_secret_latest.secret_string
  }))
  key_name = aws_key_pair.github_runner.key_name

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price                      = 0.0500
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    security_groups             = [aws_security_group.github_runner_security_group.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.compulsory_tags, {
      Name : "GitHub-Runner-Launch-Template-${var.environment}"
    })
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 60
      delete_on_termination = "true"
      volume_type           = "gp3"
    }
  }

  provider = aws.digital_platform
}

resource "aws_autoscaling_group" "github_runner" {
  name = "github_runner_auto_scaling_group"
  vpc_zone_identifier = [
    module.flex_environment.public_subnets.ids[0], module.flex_environment.public_subnets.ids[1]
  ]
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true

  termination_policies = [
    "ClosestToNextInstanceHour",
    "OldestLaunchConfiguration",
    "OldestInstance",
    "NewestInstance",
  ]

  launch_template {
    id      = aws_launch_template.github_runner.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
  }
  provider = aws.digital_platform
}
