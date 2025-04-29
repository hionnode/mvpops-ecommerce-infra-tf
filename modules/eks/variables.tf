# modules/eks/variables.tf
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}
variable "cluster_version" {
  description = "Desired Kubernetes version for the EKS cluster."
  type        = string
}
variable "vpc_id" {
  description = "ID of the VPC where the cluster will be deployed."
  type        = string
}
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster ENIs and Node Groups."
  type        = list(string)
}
variable "cluster_iam_role_arn" {
  description = "ARN of the IAM role for the EKS cluster control plane."
  type        = string
}
variable "node_group_iam_role_arn" {
  description = "ARN of the IAM role for the EKS managed node groups."
  type        = string
}
variable "eks_managed_node_groups" {
  description = "Map of objects defining managed node groups."
  type        = any # Use a specific object type for production
  default     = {}
  # Example Structure:
  # {
  #   primary = {
  #     instance_types = ["t3.medium"]
  #     min_size       = 1
  #     max_size       = 3
  #     desired_size   = 2
  #     disk_size      = 20
  #     # Optional: subnet_ids = [...] # Defaults to var.subnet_ids if not provided
  #     # Optional: tags = { ... }
  #   }
  # }
}
variable "tags" {
  description = "Tags to apply to the EKS cluster resources."
  type        = map(string)
  default     = {}
}