# environments/dev/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Match version used in bootstrap or set appropriate constraint
    }
  }
  # The backend configuration is in backend.tf
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Define common local values, like tags merging environment/project info
locals {
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    },
    var.tags # Merge with tags provided via variables, if any
  )
}

# Foundational AWS resources will be defined below in Step 6