# Terrafom

## Terraform S3 state file bucket and DynamoDB State Lock setup

* This process is needed only 1 time. Unless you are deploying a complete new environment.

S3 is the best way to store the terraform state file remotely so that many people can access it. In order to setup terraform to store state remotely you need two things: an s3 bucket to store the state file in and an terraform s3 backend resource. If the state file is stored remotely so that many people can access it, then you risk multiple people attempting to make changes to the same file at the exact same time. So we need to provide a mechanism that will “lock” the state if its currently in-use by another user. We can accomplish this by creating a dynamoDB table for terraform to use.

Steps to set the S3 bucket:

1. cd s3-state-bucket
2. Change the provider, region and bucket name to fit your needs.
3. terraform init
4. terraform plan -out plan.out
5. terraform apply plan.out

## Terraform backend

Modify the terraform main templates backed file `terraform.tf` to match the bucket name and dynamoDB table.

1. Go back to the root folder.
2. Change the `terraform.tf` accordingly.
