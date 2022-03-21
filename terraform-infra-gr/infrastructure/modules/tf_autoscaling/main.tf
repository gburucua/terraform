locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier

  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)

  eks = var.eks_cluster_id != "" ? [1] : []
}

resource "aws_launch_template" "launch_temp" {
  name_prefix            = "${local.identifier}-"
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = var.user_data
  update_default_version = var.update_default_version
  block_device_mappings {
    device_name = var.device_name
    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      iops                  = var.iops
      throughput            = var.throughput
      delete_on_termination = var.delete_on_termination
      encrypted             = var.encrypted
    }
  }
  iam_instance_profile {
    arn = var.iam_instance_profile
  }
  monitoring {
    enabled = var.monitoring
  }
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_groups
  }

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type
    }
  }

  credit_specification {
    cpu_credits = var.credit_specification
  }
  tag_specifications {
    resource_type = var.resource_type
    tags          = merge(local.default_tags, var.tags)
  }
}


resource "aws_autoscaling_group" "asg" {
  protect_from_scale_in     = var.protect_from_scale_in
  vpc_zone_identifier       = var.subnets
  desired_capacity          = var.min_size
  name_prefix               = "${local.identifier}-"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
  launch_template {
    id      = aws_launch_template.launch_temp.id
    version = aws_launch_template.launch_temp.latest_version
  }

  depends_on = [aws_launch_template.launch_temp]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      propagate_at_launch = true
      value               = tag.value
      key                 = tag.key
    }
  }

  dynamic "tag" {
    for_each = local.eks
    content {
      propagate_at_launch = true
      value               = "owned"
      key                 = "kubernetes.io/cluster/${var.eks_cluster_id}"
    }
  }
}
