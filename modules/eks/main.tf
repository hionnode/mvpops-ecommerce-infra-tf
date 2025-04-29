resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_iam_role_arn

  vpc_config {
    subnet_ids            = var.subnet_ids # Control plane ENIs go here
    endpoint_public_access  = true # Set to false for private endpoint
    # public_access_cidrs = ["0.0.0.0/0"] # Restrict access if needed
  }


  tags = merge(var.tags, {
    Name = var.cluster_name
  })

  # Ensure IAM role exists before creating cluster
  # depends_on = [
  #   aws_iam_role_policy_attachment.cluster_policy # Assuming role is created in iam_eks module
  # ]
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  # Construct the URL based on the cluster's OIDC issuer URL
  # Need to wait for cluster creation, hence data source depends_on
  url        = aws_eks_cluster.this.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.this]
}


# --- Managed Node Groups ---
resource "aws_eks_node_group" "managed" {
  for_each = var.eks_managed_node_groups # Create one node group per map key

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key # Use map key as node group name suffix/identifier
  node_role_arn   = var.node_group_iam_role_arn
  # Use subnets provided in node group definition, or default to cluster subnets
  subnet_ids      = lookup(each.value, "subnet_ids", var.subnet_ids)

  instance_types = lookup(each.value, "instance_types", ["t3.medium"]) # Example default
  disk_size      = lookup(each.value, "disk_size", 20)                # Example default

  scaling_config {
    desired_size = lookup(each.value, "desired_size", 1)
    min_size     = lookup(each.value, "min_size", 1)
    max_size     = lookup(each.value, "max_size", 3)
  }

  # Add other configurations like labels, taints, capacity type (SPOT/ON_DEMAND) as needed
  # capacity_type = lookup(each.value, "capacity_type", "ON_DEMAND")

  tags = merge(var.tags, lookup(each.value, "tags", {}), {
    Name                                          = "${var.cluster_name}-${each.key}-node-group"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = var.cluster_name # Common tag for auto-discovery
    "k8s.io/cluster-autoscaler/enabled"           = "true"           # Tag for cluster autoscaler
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"          # Tag for cluster autoscaler
  })

  # Ensure Cluster and Node Role exist first
  depends_on = [
    aws_eks_cluster.this,
    # aws_iam_role_policy_attachment.node_eks_worker_policy # Assuming role created in iam_eks module
  ]
}