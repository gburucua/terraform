output "output" {
  description = "Listener rule object"
  value = {
    listener_rule = aws_lb_listener_rule.this
  }
}
