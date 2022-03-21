variable "cdn_price_class" {
  type        = string
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_All"
}

variable "cdn_http_version" {
  type        = string
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1 and http2. The default is http2."
  default     = "http2"
}

variable "cdn_ipv6_enabled" {
  type        = bool
  description = "Whether the IPv6 is enabled for the distribution."
  default     = true
}

variable "cdn_enabled" {
  type        = bool
  description = "Whether the distribution is enabled to accept end user requests for content (the distribution is created but may be disabled)."
  default     = true
}

variable "cdn_origin" {
  type        = string
  description = "A key that indicates which of the dns_records_public should be the origin for the CDN distribution. If null, the origin will be set to the created public Load Balancer address, instead of a DNS record that targets the Load Balancer."
  default     = null
}

variable "cdn_dns_record" {
  type        = string
  description = "The DNS record to create for the CDN in the hosted zone (provided by dns_hosted_zone_id). If null, no DNS record will be created for the CDN distribution."
  default     = null
}

variable "cdn_ssl_certificate_arn" {
  type        = string
  description = "The ARN identifier of an existing Certificate in AWS Certificate Manager, to be used for the CDN distribution. If not defined, a new certificate will be issued and validated in the AWS Certificate Manager."
  default     = null
}

variable "cdn_allowed_methods" {
  type        = list(string)
  description = "Controls which HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin. There are three choices:\n - CloudFront forwards only GET and HEAD requests.\n - CloudFront forwards only GET, HEAD, and OPTIONS requests.\n - CloudFront forwards GET, HEAD, OPTIONS, PUT, PATCH, POST, and DELETE requests."
  default     = ["GET", "HEAD"]
}

variable "cdn_cached_methods" {
  type        = list(string)
  description = "Controls whether CloudFront caches the response to requests using the specified HTTP methods. There are two choices:\n - CloudFront caches responses to GET and HEAD requests.\n - CloudFront caches responses to GET, HEAD, and OPTIONS requests."
  default     = ["GET", "HEAD"]
}

variable "cdn_compress" {
  type        = bool
  description = "Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header (default: false)."
  default     = false
}

variable "cdn_default_ttl" {
  type        = number
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header. Defaults to 1 day."
  default     = 86400
}

variable "cdn_max_ttl" {
  type        = number
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of Cache-Control max-age, Cache-Control s-maxage, and Expires headers. Defaults to 365 days."
  default     = 31536000
}

variable "cdn_min_ttl" {
  type        = number
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0 seconds."
  default     = 0
}

variable "cdn_smooth_streaming" {
  type        = bool
  description = "Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior."
  default     = false
}

variable "cdn_viewer_protocol_policy" {
  type        = string
  description = " (Required) - Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId when a request matches the path pattern in PathPattern. One of allow-all, https-only, or redirect-to-https."
  default     = "allow-all"
}

variable "cdn_forwarded_headers" {
  type        = list(string)
  description = "Specifies the Headers, if any, that you want CloudFront to vary upon for this cache behavior. Specify * to include all headers."
  default     = []
}

variable "cdn_forward_query_string" {
  type        = bool
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  default     = false
}

variable "cdn_query_string_cache_keys" {
  type        = list(string)
  description = "When specified, along with a value of true for query_string, all query strings are forwarded, however only the query string keys listed in this argument are cached. When omitted with a value of true for query_string, all query string keys are cached."
  default     = []
}

variable "cdn_cookies_forward" {
  type        = string
  description = "Specifies whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior. You can specify all, none or whitelist. If whitelist, you must include the subsequent whitelisted_names"
  default     = "none"
}

variable "cdn_cookies_whitelisted_names" {
  type        = list(string)
  description = "If you have specified whitelist to forward, the whitelisted cookies that you want CloudFront to forward to your origin."
  default     = []
}

variable "cdn_ordered_cache_behaviors" {
  type = list(object({
    path_pattern              = string
    allowed_methods           = list(string)
    cached_methods            = list(string)
    compress                  = bool
    default_ttl               = number
    max_ttl                   = number
    min_ttl                   = number
    smooth_streaming          = bool
    viewer_protocol_policy    = string
    forwarded_headers         = list(string)
    forward_query_string      = bool
    query_string_cache_keys   = list(string)
    cookies_forward           = string
    cookies_whitelisted_names = list(string)
  }))
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  default     = []
}

variable "cdn_geo_restriction_locations" {
  type        = list(string)
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (whitelist) or not distribute your content (blacklist)."
  default     = []
}

variable "cdn_geo_restriction_type" {
  type        = string
  description = "The method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist."
  default     = "none"
}

variable "cdn_wait_for_deployment" {
  type        = bool
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process. Default: true"
  default     = true
}

variable "identifier" {
  description = "Identifier for all the resource"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map
}

variable "append_workspace" {
  description = "Appends the terraform workspace at the end of resource names, <identifier>-<worspace>"
  default     = true
  type        = bool
}

variable "load_balancer" {
  description = "Load balancer to use in cdn"
  default     = ""
  type        = string
}

variable "zone_name" {
  description = "Name of hosted zone"
  default     = ""
  type        = string
}
