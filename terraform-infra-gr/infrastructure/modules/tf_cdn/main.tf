locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_cloudfront_distribution" "lb_distribution" {

  # aliases = [var.zone_name]

  enabled         = var.cdn_enabled
  http_version    = var.cdn_http_version
  is_ipv6_enabled = var.cdn_ipv6_enabled
  price_class     = var.cdn_price_class

  origin {
    origin_id   = "main"
    domain_name = var.load_balancer
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  default_cache_behavior {
    target_origin_id = "main"

    allowed_methods        = var.cdn_allowed_methods
    cached_methods         = var.cdn_cached_methods
    compress               = var.cdn_compress
    default_ttl            = var.cdn_default_ttl
    max_ttl                = var.cdn_max_ttl
    min_ttl                = var.cdn_min_ttl
    smooth_streaming       = var.cdn_smooth_streaming
    viewer_protocol_policy = var.cdn_viewer_protocol_policy

    forwarded_values {
      headers                 = var.cdn_forwarded_headers
      query_string            = var.cdn_forward_query_string
      query_string_cache_keys = var.cdn_query_string_cache_keys

      cookies {
        forward           = var.cdn_cookies_forward
        whitelisted_names = var.cdn_cookies_whitelisted_names
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cdn_ordered_cache_behaviors
    iterator = behavior
    content {
      target_origin_id = "main"

      path_pattern           = behavior.value["path_pattern"]
      allowed_methods        = behavior.value["allowed_methods"]
      cached_methods         = behavior.value["cached_methods"]
      compress               = behavior.value["compress"]
      default_ttl            = behavior.value["default_ttl"]
      max_ttl                = behavior.value["max_ttl"]
      min_ttl                = behavior.value["min_ttl"]
      smooth_streaming       = behavior.value["smooth_streaming"]
      viewer_protocol_policy = behavior.value["viewer_protocol_policy"]

      forwarded_values {
        headers                 = behavior.value["forwarded_headers"]
        query_string            = behavior.value["forward_query_string"]
        query_string_cache_keys = behavior.value["query_string_cache_keys"]

        cookies {
          forward           = behavior.value["cookies_forward"]
          whitelisted_names = behavior.value["cookies_whitelisted_names"]
        }
      }
    }
  }

  # TLS configuration
  viewer_certificate {
    cloudfront_default_certificate = true
    # acm_certificate_arn            = var.cdn_ssl_certificate_arn
    # cloudfront_default_certificate = false
    # minimum_protocol_version       = "TLSv1.2_2019"
    # ssl_support_method             = "sni-only"
  }

  # Geographical restriction
  restrictions {
    geo_restriction {
      locations        = var.cdn_geo_restriction_locations
      restriction_type = var.cdn_geo_restriction_type
    }
  }

  # tags
  tags = local.tags

  # terraform resource behavior
  retain_on_delete    = false
  wait_for_deployment = var.cdn_wait_for_deployment
}

# DNS record that targets the CDN distribution (optional)
resource "aws_route53_record" "quortex_cdn" {
  zone_id = "Z07578923GYCCO2VV4X5Q"
  name    = "new.${var.zone_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.lb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.lb_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
