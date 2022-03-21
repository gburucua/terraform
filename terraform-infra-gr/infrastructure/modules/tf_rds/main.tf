locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}

resource "random_password" "password" {
  special = false
  length  = 16

  keepers = {
    static = "1"
  }
}

resource "aws_ssm_parameter" "secret" {
  description = "The parameter description"
  value       = random_password.password.result
  name        = "/${var.identifier}-${terraform.workspace}/database/${var.rds_master_username}"
  type        = "SecureString"

  tags = local.tags
}

resource "aws_db_subnet_group" "main" {
  description = "RDS Subnet Group - ${terraform.workspace}"
  subnet_ids  = var.subnets
  name        = "${var.identifier}-${terraform.workspace}"

  tags = local.tags
}

resource "aws_db_parameter_group" "main" {
  family = var.rds_parameter_group_family
  name   = "${var.identifier}-${terraform.workspace}"

  tags = local.tags
}


resource "aws_db_instance" "main" {
  # allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  # final_snapshot_identifier   = local.identifier
  backup_retention_period     = var.backup_retention_period
  vpc_security_group_ids      = var.security_groups
  parameter_group_name        = aws_db_parameter_group.main.id # var.rds_manual_parameter_group
  db_subnet_group_name        = aws_db_subnet_group.main.id  # var.custom_subnet_group
  publicly_accessible         = var.publicly_accessible
  skip_final_snapshot         = var.skip_final_snapshot
  storage_encrypted           = var.encryption
  allocated_storage           = var.rds_allocated_storage
  copy_tags_to_snapshot       = true
  deletion_protection         = true
  monitoring_interval         = "0"
  performance_insights_enabled = true
  max_allocated_storage       = "1000"
  apply_immediately           = terraform.workspace == "production" ? false : true
  engine_version              = var.rds_engine_version
  license_model               = "license-included"
  instance_class              = var.rds_instance_class
  storage_type                = var.storage_type
  identifier                  = var.custom_name_id
  username                    = var.rds_master_username
  password                    = var.password == null ? random_password.password.result : var.password
  multi_az                    = var.multi_az
  engine                      = var.engine
  domain                      = var.domain
  domain_iam_role_name        = "rds-directoryservice-access-role"
  enabled_cloudwatch_logs_exports = ["agent", "error"]
  name                        = null

  tags = local.tags
}
