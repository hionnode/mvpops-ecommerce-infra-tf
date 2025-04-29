# modules/iam_eks/outputs.tf
output "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster control plane."
  value       = aws_iam_role.cluster.arn
}
output "node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node groups."
  value       = aws_iam_role.node_group.arn
}