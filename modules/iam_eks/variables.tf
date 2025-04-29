# modules/iam_eks/variables.tf
variable "cluster_name" {
  description = "EKS Cluster name, used for potential tagging or naming conventions."
  type        = string
  default     = null # Optional
}
variable "tags" {
  description = "Tags to apply to the IAM roles."
  type        = map(string)
  default     = {}
}