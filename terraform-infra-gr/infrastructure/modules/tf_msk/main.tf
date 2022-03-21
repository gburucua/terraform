locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = "${var.identifier}-${terraform.workspace}"
  }
  tags = merge(local.default_tags, var.tags)
}



resource "aws_kms_key" "kms" {
  description = "example"
}

resource "aws_msk_cluster" "gr_cluster_01" {
  cluster_name           = local.identifier
  kafka_version          = "2.4.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 1000
    client_subnets  = var.private_subnets
    security_groups = var.vpc_security_group_ids
  }
}
# /*   encryption_info {
#     encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
#   } */

#   /* open_monitoring {
#     prometheus {
#       jmx_exporter {
#         enabled_in_broker = true
#       }
#       node_exporter {
#         enabled_in_broker = true
#       }
#     }
#   } */

# /*   logging_info {
#     broker_logs {
#       cloudwatch_logs {
#         enabled   = true
#         log_group = aws_cloudwatch_log_group.test.name
#       }
#       firehose {
#         enabled         = true
#         delivery_stream = aws_kinesis_firehose_delivery_stream.test_stream.name
#       }
#       s3 {
#         enabled = true
#         bucket  = aws_s3_bucket.bucket.id
#         prefix  = "logs/msk-"
#       }
#     }
#   }

#   tags = {
#     foo = "bar"
#   }
# } */