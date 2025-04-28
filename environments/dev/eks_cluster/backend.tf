# environments/dev/eks_cluster/backend.tf
terraform {
  backend "s3" {
    bucket         = "mvpops-ecommerce-dev-tfstate-s3" # Same bucket
    key            = "ecommerce/eks_cluster/dev/terraform.tfstate" # NEW key for EKS state
    region         = "us-east-1"                       # Same region
    dynamodb_table = "terraform-lock-dev"              # Same lock table
    encrypt        = true
  }
}