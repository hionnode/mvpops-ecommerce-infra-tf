terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a specific constraint suitable for your project
    }
  }
  # NO backend block here - uses local state for this bootstrap step
}

provider "aws" {
  region = "us-east-1" # Target region for backend resources
}

# Define common values for naming and tagging
locals {
  environment = "dev"                # Target environment for this backend setup
  project     = "mvpops-ecommerce"   # Base project name
  region      = "us-east-1"          # Match provider region

  # Naming conventions for the backend resources
  s3_bucket_name    = "${local.project}-${local.environment}-tfstate-s3"
  dynamodb_table_name = "terraform-lock-${local.environment}"

  # Common tags applied to backend resources
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    Purpose     = "TerraformBackend"
  }
}

# S3 Bucket for Terraform State storage (Private Resource)
module "tfstate_s3_bucket" {
  source = "../modules/s3_bucket" # Relative path to the public module

  bucket_name       = local.s3_bucket_name
  tags              = local.common_tags
  enable_versioning = true # Critical for state history/recovery
}

# DynamoDB Table for Terraform State Locking (Private Resource)
module "tfstate_dynamodb_table" {
  source = "../modules/dynamodb_table" # Relative path to the public module

  table_name    = local.dynamodb_table_name
  hash_key_name = "LockID" # Required key name for Terraform S3 backend locking
  hash_key_type = "S"      # Must be String type
  tags          = local.common_tags
}

# Output the names of the created private resources for reference
output "tfstate_s3_bucket_name" {
  description = "Name of the S3 bucket created for Terraform remote state."
  value       = module.tfstate_s3_bucket.bucket_id
}

output "tfstate_dynamodb_table_name" {
  description = "Name of the DynamoDB table created for Terraform state locking."
  value       = module.tfstate_dynamodb_table.table_name
}