# environments/dev/variables.tf
variable "aws_region" {
  description = "The AWS region where the environment resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The name of the deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "A short identifier for the project, used in resource naming."
  type        = string
  default     = "mvpops-ecommerce"
}

variable "domain_name" {
  description = "The primary domain name for the application (e.g., example.com)."
  type        = string
  default     = "mvpops.dev" # Use the example domain
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default = {
    # Default tags are applied, can be merged/overridden per resource
  }
}

variable "vpc_cidr" {
  description = "the CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs"{
  description = "list of availability zones to use for the vpc."
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_public_subnets"{
  description = "list of CIDR blocks for public subnets"
  type = list(string)
  default = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
}

variable "vpc_private_subnets" {
  description = "list of cidr blocks for private subnets"
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}