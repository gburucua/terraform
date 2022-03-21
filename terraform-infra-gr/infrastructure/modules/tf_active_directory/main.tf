locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
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
  name        = "/${var.identifier}-${terraform.workspace}/ad/password"
  type        = "SecureString"

  tags = local.tags
}

resource "aws_directory_service_directory" "main" {
  name     = var.ad_name
  password = random_password.password.result
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  tags = local.tags
}
#
# resource ad_user "vocusiis" {
#     display_name     = "vocusiis"
#     principal_name   = "vocusiis"
#     sam_account_name = "vocusiis"
#     initial_password = "SuperSecure1234!!"
# }
#
# resource ad_user "vocusservices" {
#     display_name     = "vocusservices"
#     principal_name   = "vocusservices"
#     sam_account_name = "vocusservices"
#     initial_password = "SuperSecure1234!!"
# }
#
# resource ad_group_membership "gm" {
#     group_id = ad_group.Admins.id
#     group_members  = [ ad_group.Admins.id, ad_user.vocusiis.id, ad_user.vocusservices.id ]
# }
