# modules/vpc/variables.tf
variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}
variable "cidr" {
  description = "The primary IPv4 CIDR block for the VPC."
  type        = string
}
variable "azs" {
  description = "List of Availability Zones to use for subnets (e.g., [\"us-east-1a\", \"us-east-1b\", \"us-east-1c\"])"
  type        = list(string)
}
variable "private_subnets" {
  description = "List of IPv4 CIDR blocks for private subnets (should match number of AZs)."
  type        = list(string)
}
variable "public_subnets" {
  description = "List of IPv4 CIDR blocks for public subnets (should match number of AZs)."
  type        = list(string)
}
variable "enable_nat_gateway" {
  description = "Should NAT Gateways be created for private subnets?"
  type        = bool
  default     = true
}
variable "single_nat_gateway" {
  description = "Should only one NAT Gateway be created and shared across all private subnets?"
  type        = bool
  default     = true # Cost optimization for dev/test
}
variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
variable "public_subnet_tags" {
  description = "Additional tags to apply to public subnets."
  type        = map(string)
  default     = {}
}
variable "private_subnet_tags" {
  description = "Additional tags to apply to private subnets."
  type        = map(string)
  default     = {}
}

variable "enable_dns_hostnames" {
  description = "Specifies whether DNS hostnames are enabled for the VPC."
  type        = bool
  default     = true
}
variable "enable_dns_support" {
  description = "Specifies whether DNS resolution is enabled for the VPC."
  type        = bool
  default     = true
}