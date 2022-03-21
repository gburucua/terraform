variable "identifier" {
  description = "The name for the resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource"
  default     = {}
  type        = map(any)
}


variable "bucket" {
  description = "Bucket name"
  default     = ""
  type        = string
}

variable "acl" {
  description = "Access list for the bucket"
  default     = "private"
  type        = string
}

variable "append_workspace" {
  description = "Appends the terraform workspace at the end of resource names, <identifier>-<worspace>"
  default     = true
  type        = bool
}
