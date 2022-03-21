variable "vpc_id" {
  description = "The VPC where all the resources belong"
  default     = ""
  type        = string
}

variable "subnet_ids" {
  description = "List of all the subnets"
  default     = []
  type        = list(string)
}

variable "domain_ad_name" {
  description = "name of Active Directory"
  default     = ""
  type        = string
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

variable "fsx_storage_capacity" {
  description = "Storage_capacity"
  default     = "50"
  type        = string
}

variable "active_directory_id" {}