vpc_id          = "vpc-0fd580153a9f5f711"

public_subnets  = ["subnet-062d66192f54fb013", "subnet-0de5e0131be290f9e", "subnet-02f98b4bcae8a535b"]
private_subnets = ["subnet-0cf5ff5969cc999aa", "subnet-03933930cb6833592", "subnet-03ad23a394f4b6fa3"]
db_subnets      = ["subnet-08f64c513e3c2a98b", "subnet-0ca25d996bba0c81d", "subnet-03da09447c87e670f"]
tgw_subnets     = ["subnet-0aeb92d37c0422709", "subnet-098c86baae4fdd860", "subnet-0bf35cc00b736c787"]


####### AMIs ############

ami_Jump_Box                 = "ami-022ff0e4fc122fdbf"
ami_SQL_Tool                 = "ami-0ee76af689dbb08c0"
ami_bamboo                   = "ami-0971781aa93aa7f84"
ami_SecretSauce_SystemUpdate = "ami-00e2ba6d22008244b"
ami_SecretSauce_JS           = "ami-0dd49cffe6034b739"
ami_SecretSauce_WS           = "ami-0b3586f291b846e08"
ami_SecretSauce_TS           = "ami-0be178a64e285c19a"
ami_win_2019                 = "ami-05b1913800455eb71" #pzipcode
ami_msenterpriseca           = "ami-08c049a868f6794bf"
ami_utility                  = "ami-066917d8e0845a7d9"
ami_p2p                      = "ami-01dc497eba27fc547"
ami_p2p_nginx                = "ami-06d9e5be7e39d25da" #linux
ami_redis_slave              = "ami-021af2c7b23c4934f" #linux
ami_redis_master             = "ami-061fbb4a829f197f9" #linux 




key_name        = "quorum-prod"

db_instance_type = "db.m5.xlarge"
engine =  "sqlserver-se"
rds_engine_version = "15.00.4073.23.v1"
rds_parameter_group_family = "sqlserver-se-15.0"

tags = {
  Origin             = "terraform"
  Owner              = "Cision"
  "user:cost-center" = "GR"
  "user:environment" = "prod-quorum"
  "user:app-role"    = "prod-quorum"
  "user:version"     = "1"
}
