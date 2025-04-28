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

# environments/dev/main.tf
# (terraform, provider, locals blocks are already here from Step 5)

# --- Foundational Resources ---

# Application Assets S3 Bucket (Private Resource defined by Public Code)
module "app_assets_s3_bucket" {
  source = "../../../modules/s3_bucket" # Relative path to the public s3_bucket module

  bucket_name = "${var.project_name}-${var.environment}-assets-s3" # e.g., mvpops-ecommerce-dev-assets-s3
  tags        = merge(local.common_tags, { Purpose = "ApplicationAssets" })

  # Module defaults ensure versioning, encryption, public access block.
  # Override module variables here if different settings are needed for this bucket.
}

# Route 53 Public Hosted Zone (Public DNS Resource)
# Manages the DNS zone for the domain specified in var.domain_name
resource "aws_route53_zone" "primary" {
  name = var.domain_name # e.g., "mvpops.dev"
  tags = merge(local.common_tags, { Purpose = "PrimaryDNS" })
}

# AWS Simple Email Service (SES) Domain Identity (Configuration Resource)
# Verifies domain ownership to allow sending emails from the domain.
resource "aws_ses_domain_identity" "primary" {
  domain = var.domain_name # e.g., "mvpops.dev"
}

# Route53 TXT Record for SES Domain Verification (Public DNS Record)
# This record proves domain ownership to AWS SES.
resource "aws_route53_record" "ses_domain_verification_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600" # Time-to-live in seconds
  # SES provides a unique token that must be placed in this TXT record.
  records = [aws_ses_domain_identity.primary.verification_token]
}

# AWS SES Domain DKIM Generation (Configuration Resource)
# Generates DKIM tokens necessary for setting up DKIM email authentication.
resource "aws_ses_domain_dkim" "primary_dkim" {
  domain = aws_ses_domain_identity.primary.domain
}

# Route53 CNAME Records for SES DKIM Verification (Public DNS Records)
# Creates the 3 CNAME records required by AWS SES to enable DKIM signing.
resource "aws_route53_record" "ses_domain_dkim_verification_records" {
  count   = 3 # SES provides 3 DKIM tokens/records
  zone_id = aws_route53_zone.primary.zone_id
  name    = "${element(aws_ses_domain_dkim.primary_dkim.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.primary_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# -- phase 1: networking infrastructure --

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.0"

#   name = "${var.project_name}-${var.environment}-vpc"
#   cidr = var.vpc_cidr
#   azs = var.vpc_azs
#   private_subnets = var.vpc_private_subnets
#   public_subnets = var.vpc_public_subnets
# }