# environments/dev/eks_cluster/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Ensure consistency
    }
    # Potentially add 'kubernetes' and 'helm' providers later if needed
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Remote State Data Source ---
# Reads outputs from the persistent foundation state file
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "mvpops-ecommerce-dev-tfstate-s3" # Should match your TF state bucket name
    key    = "ecommerce/foundation/dev/terraform.tfstate" # Key of the foundation state
    region = var.aws_region
  }
}

# --- Locals ---
locals {
  cluster_name = "${var.project_name}-${var.environment}-eks-cluster"
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      StateScope  = "EKS_Cluster" # Tag indicating management scope
    },
    var.tags
  )
  # Example of using remote state output:
  foundation_route53_zone_id = data.terraform_remote_state.foundation.outputs.route53_zone_id
}

# --- Networking (VPC) ---
# Provides the network foundation for the EKS cluster
data "aws_availability_zones" "available" {
  # Fetches available AZs in the current region
  state = "available"
}

module "vpc" {
  source = "../../../modules/vpc" # Adjust path to your VPC module

  name               = "${var.project_name}-${var.environment}-vpc"
  cidr               = var.vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, 3) # Use first 3 available AZs
  private_subnets    = var.private_subnet_cidrs
  public_subnets     = var.public_subnet_cidrs

  enable_nat_gateway = true # Set to true if private nodes need internet access
  single_nat_gateway = true # Optional: Use one NAT GW for cost saving in dev
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
  public_subnet_tags = { "kubernetes.io/role/elb" = "1" } # Tags for AWS Load Balancer Controller discovery
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" } # Tags for internal ELBs & node placement
}

# --- IAM Roles for EKS ---
# Creates the necessary IAM roles for the EKS control plane and node groups
module "iam_eks" {
  source = "../../../modules/iam_eks" # Adjust path to your IAM EKS module

  cluster_name          = local.cluster_name # Pass cluster name if needed by module logic
  tags                  = local.common_tags
  # Add inputs here if your module creates IRSA roles, e.g.:
  # create_aws_load_balancer_controller_role = true
  # create_ebs_csi_driver_role = true
}

# --- EKS Cluster ---
# Provisions the EKS control plane and managed node groups
module "eks" {
  source = "../../../modules/eks" # Adjust path to your EKS module (e.g., terraform-aws-modules/eks/aws)

  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids # Place control plane ENIs and nodes in private subnets

  cluster_iam_role_arn = module.iam_eks.cluster_role_arn # Get Role ARN from the IAM module
  node_group_iam_role_arn = module.iam_eks.node_group_role_arn
  # Define the primary managed node group
  eks_managed_node_groups = {
    primary = {
      name           = "${var.project_name}-${var.environment}-primary-nodes"
      instance_types = [var.eks_node_instance_type]
      min_size       = var.eks_node_min_count
      max_size       = var.eks_node_max_count
      desired_size   = var.eks_node_desired_count

      # Ensure nodes are placed in the private subnets created by the VPC module
      subnet_ids     = module.vpc.private_subnet_ids

      # Attach the IAM role created by the IAM module
      iam_role_arn   = module.iam_eks.node_group_role_arn

      # Add tags specific to the node group
      tags           = merge(local.common_tags, { Purpose = "EKS_Nodes_Primary" })
    }
    # Add definitions for other node groups if needed (e.g., spot instances, GPU nodes)
  }

  # Enable IRSA (IAM Roles for Service Accounts)
  # enable_irsa = true

  # Add cluster tags
  tags = local.common_tags

  # Explicit dependency to ensure VPC and IAM Roles are created first
  depends_on = [module.vpc, module.iam_eks]
}
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  # Get the OIDC issuer URL directly from the EKS module output
  url = module.eks.oidc_provider_url # Adjust output name if your module differs

  # List of client IDs (audiences) that are allowed.
  # 'sts.amazonaws.com' is required for IAM role assumption.
  client_id_list = ["sts.amazonaws.com"]

  # Get the thumbprint of the root CA certificate for the OIDC provider URL
  # Terraform can fetch this automatically.
  thumbprint_list = [] # Terraform >= 4.3.0 automatically computes this

  tags = local.common_tags
}
# --- Optional: Explicit IRSA Role Definitions ---
# Define specific roles here if they are NOT created within the iam_eks module
# Example for AWS Load Balancer Controller:
/*
module "iam_assumable_role_lbc" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "~> 5.0" # Check for latest appropriate version
  create_role  = true
  role_name    = "${local.cluster_name}-lbc-sa-role"
  provider_url = module.eks.oidc_provider # Reference OIDC provider output from EKS module
  role_policy_arns = {
    lbc_policy = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy" # Attach the AWS managed policy
  }
  # Match the ServiceAccount namespace and name used in your K8s deployment
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
  tags = merge(local.common_tags, { Purpose = "IRSA_Role_LBC" })
}
*/