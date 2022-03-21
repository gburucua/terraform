variable "lb_is_internal" {
  description = "Boolean that represent if the load balancer will be internal or no"
  default     = false
  type        = bool
}

variable "vpc_id" {
  description = "The VPC where all the resources belong"
  default     = ""
  type        = string
}

variable "security_groups" {
  description = "Security group"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of all the subnets"
  default     = []
  type        = list(string)
}

variable "alb_certificate_arn" {
  description = "ARN for the load balancer certificate"
  default     = []
  type        = list(string)
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

variable "target_group_arn" {
  default     = ""
  type        = string
}
