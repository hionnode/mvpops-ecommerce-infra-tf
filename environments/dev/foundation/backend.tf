# environments/dev/foundation/backend.tf
terraform {
  backend "s3" {
    bucket         = "mvpops-ecommerce-dev-tfstate-s3" # Your existing TF state bucket
    key            = "ecommerce/foundation/dev/terraform.tfstate" # NEW key for foundation state
    region         = "us-east-1"                       # Your AWS region
    dynamodb_table = "terraform-lock-dev"              # Your existing TF lock table
    encrypt        = true
  }
}