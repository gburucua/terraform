output "output" {
  value = {
    cloudfront = aws_cloudfront_distribution.lb_distribution

  }
}
