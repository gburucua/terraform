locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}


resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  # acl    = "private"
  tags = local.tags
}
