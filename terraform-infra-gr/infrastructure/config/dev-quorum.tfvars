vpc_id          = "vpc-0db199f2cdba48489"
public_subnets  = ["subnet-0d89a579e2aa39a85", "subnet-00313f3e983cb59be", "subnet-0a630cf6a2e1b5a81"]
private_subnets = ["subnet-0e0f37cc46f6f9897", "subnet-000acbed9279735a8", "subnet-0a60ba90f2982f2ae"]
db_subnets      = ["subnet-0d6416b36024a9c64", "subnet-03811198404053b82", "subnet-05921d39fa0ac8d94" ]
tgw_subnets     = ["subnet-07a3d5cfda792d09e", "subnet-055e5fc0512796bfc", "subnet-0f1fc746697fc65be"]

domain = "dev.vocusgr.com"
ami_SecretSauce_SystemUpdate = "ami-02460916dfe4f1473"
ami_SecretSauce_JS           = "ami-04e3eb2abd694097d"
ami_SecretSauce_WS           = "ami-0dacbbe4cd192ed72"
ami_SecretSauce_TS           = "ami-0dcfe9e1101177dd5"
#Microsoft Windows Server 2019 with SQL Server 2019 Standard
ami_SQL_Tool                 = "ami-0ca19b72e39c9917c"
ami_Jump_Box                 = "ami-0820dbe5e77e96bef"
ami_win_2019                 = "ami-0d80714a054d3360c"
ami_bamboo                   = "ami-0c13bd8d05e41c5d4"
key_name        = "dev-quorum"

db_instance_type = "db.m5.xlarge"
engine =  "sqlserver-se"
rds_engine_version = "15.00.4073.23.v1"
rds_parameter_group_family = "sqlserver-se-15.0"

tags = {
  Origin             = "terraform"
  Owner              = "Cision"
  "user:cost-center" = "GR"
  "user:environment" = "dev-quorum"
  "user:app-role"    = "dev-quorum"
  "user:version"     = "1"
}
