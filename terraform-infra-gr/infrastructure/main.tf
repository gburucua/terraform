/* #####   RDS   #####

module "rds_security_group" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-rds"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-RDS-SG",
    from_port   = 1433,
    protocol    = "TCP",
    to_port     = 1433
  }]
}

module "rds_import_gr_001" {
  source                     = "./modules/tf_rds"
  rds_database_name          = "${terraform.workspace}-quorum-gr-001"
  rds_parameter_group_family = var.rds_parameter_group_family
  rds_manual_parameter_group = "quorum-prod-rds-parm-group"
  rds_engine_version         = var.rds_engine_version
  rds_instance_class         = "db.t3.xlarge"
  security_groups            = [module.rds_sql_security_group.output.security_group.id]
  identifier                 = "${var.identifier}-${terraform.workspace}-gr-001"
  custom_name_id             = "${var.identifier}-${terraform.workspace}-gr-001"
  custom_subnet_group        = "prod-data-sg"
  domain                     = "d-906758a5d0"
  publicly_accessible        = false
  subnets                    = var.db_subnets
  vpc_id                     = var.vpc_id
  engine                     = var.engine
  tags                       = var.tags
}

module "rds_gr_alarms" {
  source                 = "./modules/tf_cloudwatch/alarms_rds"
  identifier             = "${var.identifier}-rds_gr"
  db_instance_id         = module.rds_import_gr_001.output.rds.id
  db_instance_class      = "db.t3.xlarge"
  tags                   = var.tags
}

module "rds_import_sitemgr" {
  source                     = "./modules/tf_rds"
  rds_database_name          = "${terraform.workspace}-sitemgr"
  rds_parameter_group_family = var.rds_parameter_group_family
  rds_manual_parameter_group = "quorum-prod-rds-parm-group"
  rds_engine_version         = var.rds_engine_version
  rds_instance_class         = "db.t3.xlarge"
  security_groups            = [module.rds_sql_security_group.output.security_group.id]
  identifier                 = "${var.identifier}-${terraform.workspace}-sitemgr"
  custom_name_id             = "${var.identifier}-${terraform.workspace}-sitemgr"
  custom_subnet_group        = "prod-data-sg"
  domain                     = "d-906758a5d0"
  publicly_accessible        = false
  subnets                    = var.db_subnets
  vpc_id                     = var.vpc_id
  engine                     = var.engine
  tags                       = var.tags
}

module "rds_sql_security_group" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-rds-sql"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = ["10.0.0.0/8"],
    description = "${terraform.workspace}-RDS-SG",
    from_port   = 1433,
    protocol    = "TCP",
    to_port     = 1433
  }]
} */


#####   ALB   #####

module "alb_security_group" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-alb-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
}

module "alb" {
  source           = "./modules/tf_alb"
  identifier       = "${var.identifier}-${terraform.workspace}-alb"
  security_groups  = [module.alb_security_group.output.security_group.id]
  target_group_arn = aws_alb_target_group.tg.arn
  vpc_id           = var.vpc_id
  subnet_ids       = var.public_subnets
  tags             = var.tags
}

resource "aws_alb_target_group" "tg" {
  name     = "${var.identifier}-${terraform.workspace}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = var.tags
  health_check {
    healthy_threshold = 5
    unhealthy_threshold = 3
    port = "80"
    protocol = "HTTP"
    matcher = "200-499"
  }
}

module "alb-listener-rule" {
  source       = "./modules/tf_alb_listener_rule"
  listener_arn = module.alb.output.http_listener.arn
  priority     = 100
  host_header  = ["www.google.com"]
  path_pattern = ["/*"]
  target_groups = [{
    arn = aws_alb_target_group.tg.arn
  }]
  query_strings = [{
    value = "user"
  }]
}

resource "aws_lb_target_group_attachment" "ws" {
    target_group_arn = aws_alb_target_group.tg.arn
    target_id        = module.ec2-secretsauce_ws.output.instance.id
    port             = 80
}

module "alarms_lb" {
  source                 = "./modules/tf_cloudwatch/alarms_lb"
  identifier             = "${var.identifier}-lb"
  tags                   = var.tags
  load_balancer_id       = module.alb.output.alb.id
  target_group_id        = aws_alb_target_group.tg.id
}


#####   AD   #####

module "ad" {
  source     = "./modules/tf_active_directory"
  identifier = "${var.identifier}-${terraform.workspace}-active_directory"
  ad_name    = "${terraform.workspace}.vocusgr.com"
  vpc_id     = var.vpc_id
  subnet_ids = [element(var.db_subnets, 0), element(var.db_subnets, 1) ]
  tags       = var.tags
}

#####   FSX   #####

module "fsx" {
  source     = "./modules/tf_fsx"
  active_directory_id = module.ad.output.active_directory_output.id
  subnet_ids = [element(var.db_subnets, 0)]
  tags       = var.tags
}


#####   S3   #####

module "s3_gr_data" {
  source      = "./modules/tf_s3"
  identifier  = "${var.identifier}-${terraform.workspace}-S3-GR-Data"
  bucket      = var.bucket
  acl         = var.acl
  tags        = var.tags
}


#####   WAF   #####

resource "aws_wafv2_web_acl" "example" {
  name        = "${var.identifier}-${terraform.workspace}-waf"
  description = "WAF-acl"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.identifier}-${terraform.workspace}-metric-waf"
    sampled_requests_enabled   = false
  }
}


#####   ASG   #####

# module "security_group_asg" {
#   source     = "./modules/tf_security_group"
#   identifier = "${var.identifier}-${terraform.workspace}-asg-sg"
#   vpc_id     = var.vpc_id
#   tags       = var.tags
# }

# resource "aws_iam_instance_profile" "profile" {
#   name = "${var.identifier}-${terraform.workspace}-asg_profile"
#   role = aws_iam_role.role.name
# }

# resource "aws_iam_role" "role" {
#   name = "${var.identifier}-${terraform.workspace}_role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

# module "asg" {
#   source               = "./modules/tf_autoscaling"
#   iam_instance_profile = aws_iam_instance_profile.profile.arn
#   # user_data_base64     = base64encode(local.instance_userdata)
#   security_groups      = [module.security_group_asg.output.security_group.id]
#   identifier           = var.identifier
#   image_id             = var.ami_SecretSauce_WS
#   instance_type        = "t3.medium"
#   key_name             = "${terraform.workspace}-quorum"
#   volume_size          = 30
#   subnets              = [element(var.db_subnets, 0), element(var.db_subnets, 1)]
#   tags                 = var.tags
# }


#####   EC2   #####

##### 1 JUMP BOX #####
module "security_group_jump_box" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-jump-box-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
}

module "ec2_jump_box" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_Jump_Box
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-Jump-Box"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security_group_jump_box.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}


##### 2 SQL TOOL #####
# module "security_group_sql_tool" {
#   source     = "./modules/tf_security_group"
#   identifier = "${var.identifier}-${terraform.workspace}-sql-tool"
#   vpc_id     = var.vpc_id
#   tags       = var.tags
# }

# module "ec2_sql_tool" {
#   source                 = "./modules/tf_ec2"
#   ami                    = var.ami_SQL_Tool
#   identifier             = "${var.identifier}-${terraform.workspace}-sql-tool"
#   subnet_id              = element(var.private_subnets, 0)
#   instance_type          = var.instance_type
#   vpc_security_group_ids = [module.security_group_sql_tool.output.security_group.id]
#   key_name               = var.key_name
#   tags                   = var.tags
#   extra_ebs              = true
# }

##### 3 BAMBOO SERVER #####

/* module "security_group_bamboo" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-bamboo"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}
module "ec2_bamboo" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_bamboo
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-bamboo_agent"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "m5a.2xlarge"
  vpc_security_group_ids = [module.security_group_bamboo.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}
module "alarm_ec2_bamboo_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-bamboo_agent"
  tags                   = var.tags
  instance_id            = module.ec2_bamboo.output.instance.id
} */


##### 4 SYSTEM UPDATE #####

/* module "security_group_secretsauce_systemupdate" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-secretsauce-systemupdate-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2_secretsauce_systemupdate" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_SecretSauce_SystemUpdate
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-secretsauce-systemupdate"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security_group_secretsauce_systemupdate.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_secretsauce_systemupdate_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-secretsauce-systemupdate"
  tags                   = var.tags
  instance_id            = module.ec2_secretsauce_systemupdate.output.instance.id
} */

##### 5 JS #####

module "security_group_secretsauce_js" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-secretsauce-js-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2_secretsauce_js" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_SecretSauce_JS
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-secretsauce-js"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security_group_secretsauce_js.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_secretsauce_js_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-secretsauce-js"
  tags                   = var.tags
  instance_id            = module.ec2_secretsauce_js.output.instance.id
}

##### 6 WS #####

module "security_group_secretsauce_ws" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-secretsauce-ws-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2-secretsauce_ws" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_SecretSauce_WS
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-secretsauce-ws"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security_group_secretsauce_ws.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_secretsauce_ws_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-secretsauce-ws"
  tags                   = var.tags
  instance_id            = module.ec2-secretsauce_ws.output.instance.id
}

##### 7 TS #####

module "security_group_secretsauce_ts" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-secretsauce-ts-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2_secretsauce_ts" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_SecretSauce_TS
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-secretsauce-ts"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security_group_secretsauce_ts.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_secretsauce_ts_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-secretsauce-ts"
  tags                   = var.tags
  instance_id            = module.ec2_secretsauce_ts.output.instance.id
}

##### 8 ZIPCODE #####

module "security_group_host_zipcode" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-host-pzipcode-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2_host_zipcode" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_win_2019
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-host-pzipcode"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_secretsauce_js.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_host_zipcode_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-host-pzipcode"
  tags                   = var.tags
  instance_id            = module.ec2_host_zipcode.output.instance.id
}

##### 9 msenterpriseca #####

/* module "security_group_msenterpriseca" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-msenterpriseca-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}
module "ec2_msenterpriseca" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_msenterpriseca
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-msenterpriseca"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_msenterpriseca.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}
module "alarm_ec2_msenterpriseca_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-msenterpriseca"
  tags                   = var.tags
  instance_id            = module.ec2_msenterpriseca.output.instance.id
} */

##### 10 utility #####

module "security_group_utility" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-utility-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2_utility" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_utility
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-utility"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_utility.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_utility_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-utility"
  tags                   = var.tags
  instance_id            = module.ec2_utility.output.instance.id
}

##### 11 P2P #####  

module "security_group_p2p" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-p2p-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 3389,
    protocol    = "TCP",
    to_port     = 3389
  }]
}

module "ec2_p2p" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_p2p
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-p2p"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_p2p.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_p2p_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-p2p"
  tags                   = var.tags
  instance_id            = module.ec2_p2p.output.instance.id
}


##### 12 p2p_nginx #####                      

module "security_group_p2p_nginx" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-p2p_nginx-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 22,
    protocol    = "TCP",
    to_port     = 22
  }]
}

module "ec2_p2p_nginx" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_p2p_nginx
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-p2p_nginx"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_p2p_nginx.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_p2p_nginx_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-p2p_nginx"
  tags                   = var.tags
  instance_id            = module.ec2_p2p_nginx.output.instance.id
}

##### 13 redis_slave #####

module "security_group_redis_slave" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-redis_slave-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 22,
    protocol    = "TCP",
    to_port     = 22
  }]
}

module "ec2_redis_slave" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_redis_slave
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-redis_slave"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_redis_slave.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_redis_slave_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-redis_slave"
  tags                   = var.tags
  instance_id            = module.ec2_redis_slave.output.instance.id
}

##### 14 redis_master #####

module "security_group_redis_master" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-${terraform.workspace}-redis_master-sg"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-VPN-Access",
    from_port   = 22,
    protocol    = "TCP",
    to_port     = 22
  }]
}

module "ec2_redis_master" {
  source                 = "./modules/tf_ec2"
  ami                    = var.ami_redis_master
  iam_instance_profile   = module.ad_ec2_role.output.instance_profile.id
  identifier             = "${var.identifier}-${terraform.workspace}-redis_master"
  subnet_id              = element(var.private_subnets, 0)
  instance_type          = "t2.medium"
  vpc_security_group_ids = [module.security_group_redis_master.output.security_group.id]
  key_name               = var.key_name
  tags                   = var.tags
  extra_ebs              = true
  add_eip                = false
}

module "alarm_ec2_redis_master_cpu" {
  source                 = "./modules/tf_cloudwatch/alarms_ec2"
  identifier             = "${var.identifier}-redis_master"
  tags                   = var.tags
  instance_id            = module.ec2_redis_master.output.instance.id
}


##### AD ROLE #####
module "ad_ec2_role" {
  source                 = "./modules/tf_iam_role"
  iam_policies_to_attach = var.iam_policies_to_attach_worker
  aws_service_principal  = "ec2.amazonaws.com"
  identifier             = "${var.identifier}-${terraform.workspace}-ad"
  tags                   = var.tags
}

#####   AD domain join   #####

resource "aws_ssm_document" "ad-join-domain" {
  name          = "${var.identifier}-${terraform.workspace}-ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : module.ad.output.active_directory_output.id,
            "directoryName" : module.ad.output.active_directory_output.name
            "dnsIpAddresses" : sort(module.ad.output.active_directory_output.dns_ip_addresses)
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "windows_server" {
  name = aws_ssm_document.ad-join-domain.name
  targets {
    key    = "tag:Origin"
    values = ["terraform"]
  }
}


#####   CDN   #####

module "cdn" {
  source                 = "./modules/tf_cdn"
  zone_name              = "${terraform.workspace}.vocusgr.com"
  load_balancer          = module.alb.output.dns_name
  tags                   = var.tags
}


#####   Route 53   #####

resource "aws_route53_zone" "private" {
  name = "${terraform.workspace}.vocusgr.com"

  vpc {
    vpc_id = var.vpc_id
  }
}


##### MSK ######

module "security_group_msk" {
  source     = "./modules/tf_security_group"
  identifier = "${var.identifier}-msk"
  vpc_id     = var.vpc_id
  tags       = var.tags
  ingress_rule_list = [{
    cidr_blocks = [
      "10.0.0.0/8"
    ],
    description = "${terraform.workspace}-MSK-SG",
    from_port   = 6379,
    protocol    = "TCP",
    to_port     = 6379
  }]
}

module "msk_gr_cluster_01" {
  source                 = "./modules/tf_msk"
  identifier             = "${var.identifier}-gr_cluster_01"
  vpc_security_group_ids = [module.security_group_msk.output.security_group.id]
  tags                   = var.tags
}