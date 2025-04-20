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