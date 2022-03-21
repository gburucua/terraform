locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_kms_key" "ad_key" {
  description             = "KMS key 1"
  deletion_window_in_days = 30
}

resource "aws_fsx_windows_file_system" "main" {
  active_directory_id = var.active_directory_id
  kms_key_id          = aws_kms_key.ad_key.arn
  storage_capacity    = var.fsx_storage_capacity
  subnet_ids          = var.subnet_ids
  throughput_capacity = 1024
}
