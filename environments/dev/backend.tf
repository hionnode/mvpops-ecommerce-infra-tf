# environments/dev/backend.tf
# Configures Terraform to use the S3 backend for remote state storage and locking.
# The resources referenced (bucket, dynamodb_table) are PRIVATE to your AWS account.
terraform {
  backend "s3" {
    bucket         = "mvpops-ecommerce-dev-tfstate-s3" # Name of the PRIVATE S3 bucket created in Step 4
    key            = "dev/terraform.tfstate"           # Path to the state file within the bucket for the 'dev' workspace
    region         = "us-east-1"                       # AWS Region where the bucket and table exist
    dynamodb_table = "terraform-lock-dev"              # Name of the PRIVATE DynamoDB table created in Step 4
    encrypt        = true                              # Ensures the state file is encrypted at rest in S3
  }
}