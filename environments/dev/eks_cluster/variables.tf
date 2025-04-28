# environments/dev/eks_cluster/variables.tf
variable "aws_region" {
  description = "AWS region for EKS cluster resources."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Base name for project resources."
  type        = string
  default     = "mvpops-ecommerce"
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC."
  type        = string
  default     = "10.10.0.0/16" # Example - Choose a non-overlapping range
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (typically 3 across different AZs)."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (typically 3 across different AZs)."
  type        = list(string)
  default     = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
}

variable "eks_cluster_version" {
  description = "Desired Kubernetes version for the EKS cluster (e.g., '1.29')."
  type        = string
  default     = "1.29" # Check AWS console for currently supported versions
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for the EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_count" {
  description = "Desired number of nodes in the EKS managed node group."
  type        = number
  default     = 2
}

variable "eks_node_min_count" {
  description = "Minimum number of nodes in the EKS managed node group."
  type        = number
  default     = 1
}

 variable "eks_node_max_count" {
  description = "Maximum number of nodes in the EKS managed node group."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Additional tags to apply to EKS cluster resources."
  type        = map(string)
  default     = {}
}