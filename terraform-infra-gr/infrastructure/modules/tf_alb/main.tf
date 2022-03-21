locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_alb" "main" {
  security_groups = var.security_groups
  internal        = var.lb_is_internal #tfsec:ignore:AWS005
  subnets         = var.subnet_ids
  name            = local.identifier

  tags = local.tags
}

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.main.arn
  protocol          = "HTTP"
  port              = "80"

  default_action {
    target_group_arn = var.target_group_arn
    type = "forward"

    # redirect {
    #   status_code = "HTTP_301"
    #   protocol    = "HTTPS"
    #   port        = "443"
    # }
  }
}


resource "aws_alb_listener" "https_listener" {
  count = length(var.alb_certificate_arn) > 0 ? 1 : 0

  load_balancer_arn = aws_alb.main.arn
  certificate_arn   = var.alb_certificate_arn[0]
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  protocol          = "HTTPS"
  port              = 443

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_alb_listener_certificate" "certificates" {
  count = length(var.alb_certificate_arn)

  certificate_arn = var.alb_certificate_arn[count.index]
  listener_arn    = aws_alb_listener.https_listener.0.arn
}
