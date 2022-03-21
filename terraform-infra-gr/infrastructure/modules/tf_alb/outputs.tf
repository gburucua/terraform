output "output" {
  value = {
    https_listener = length(var.alb_certificate_arn) > 0 ? aws_alb_listener.https_listener.0 : null
    http_listener  = aws_alb_listener.http_listener
    alb            = aws_alb.main
    zone_id        = aws_alb.main.zone_id
    dns_name       = aws_alb.main.dns_name

  }
}
