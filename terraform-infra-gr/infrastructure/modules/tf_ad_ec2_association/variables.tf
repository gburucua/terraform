variable "vpc_security_group_ids" {
  description = "Security group"
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

variable "subnet_id" {}

variable "ami" {}

variable "key_name" {}

variable "instance_type" {}
