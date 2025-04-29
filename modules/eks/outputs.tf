# modules/eks/outputs.tf
output "cluster_id" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.this.id
}
output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster Kubernetes API."
  value       = aws_eks_cluster.this.endpoint
}
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the EKS cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}
output "oidc_provider_url" {
  description = "URL of the EKS cluster's OIDC provider (issuer URL)."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
output "oidc_provider_arn" {
  description = "ARN of the EKS cluster's OIDC provider."
  # Fetch ARN using the data source that depends on the cluster issuer URL
  value       = data.aws_iam_openid_connect_provider.oidc_provider.arn
}
output "managed_node_group_ids" {
  description = "Map of managed node group names to their IDs."
  value       = { for k, v in aws_eks_node_group.managed : k => v.id }
}