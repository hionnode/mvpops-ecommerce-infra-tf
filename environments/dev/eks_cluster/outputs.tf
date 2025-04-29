# environments/dev/eks_cluster/outputs.tf

output "eks_cluster_id" {
  description = "The name/ID assigned to the EKS cluster."
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster's Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

# output "eks_cluster_oidc_provider_url" {
#   description = "The OIDC Identity Provider URL for the EKS cluster (used for IRSA)."
#   value       = module.eks.oidc_provider # Assumes EKS module provides this output
# }

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required by kubectl to verify the cluster API server certificate."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true # Mark as sensitive to prevent accidental exposure in logs
}

output "eks_node_group_role_arn" {
  description = "ARN of the IAM role assumed by the EKS managed node group instances."
  value       = module.iam_eks.node_group_role_arn # Assumes IAM module provides this output
}

output "eks_cluster_role_arn" {
    description = "ARN of the IAM role for the EKS Control Plane."
    value       = module.iam_eks.cluster_role_arn # Assumes IAM module provides this output
}

output "vpc_id" {
    description = "ID of the VPC created for the EKS cluster."
    value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
    description = "List of Private Subnet IDs created within the VPC."
    value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
    description = "List of Public Subnet IDs created within the VPC."
    value       = module.vpc.public_subnet_ids
}

# Add outputs for any explicitly created IRSA roles
/*
output "lbc_irsa_role_arn" {
  description = "ARN for the AWS Load Balancer Controller IAM Role for Service Account."
  value       = module.iam_assumable_role_lbc.iam_role_arn
}
*/