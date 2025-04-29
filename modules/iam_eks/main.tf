# modules/iam_eks/main.tf
locals {
  cluster_name_tag = var.cluster_name != null ? { "eks_cluster_name" = var.cluster_name } : {}
}

# --- EKS Cluster Role ---
resource "aws_iam_role" "cluster" {
  name = lower("${var.cluster_name}-cluster-role") # Example naming
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(var.tags, local.cluster_name_tag, { Name = "${var.cluster_name}-cluster-role" })
}

resource "aws_iam_policy_attachment" "cluster_policy" {
  name       = "${lower(var.cluster_name)}-cluster-policy-attach"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.cluster.name]
}

# --- EKS Node Group Role ---
resource "aws_iam_role" "node_group" {
  name = lower("${var.cluster_name}-node-group-role") # Example naming
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(var.tags, local.cluster_name_tag, { Name = "${var.cluster_name}-node-group-role" })
}

resource "aws_iam_policy_attachment" "node_eks_worker_policy" {
  name       = "${lower(var.cluster_name)}-eks-worker-policy-attach"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  roles      = [aws_iam_role.node_group.name]
}

resource "aws_iam_policy_attachment" "node_ecr_policy" {
  name       = "${lower(var.cluster_name)}-ecr-policy-attach"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.node_group.name]
}

resource "aws_iam_policy_attachment" "node_cni_policy" {
  name       = "${lower(var.cluster_name)}-cni-policy-attach"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  roles      = [aws_iam_role.node_group.name]
}

# Add attachments for other policies needed by nodes (e.g., SSM, EBS CSI Driver) here if required