variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique or use bucket_prefix."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "enable_versioning" {
  description = "Set to true to enable versioning. Recommended for state buckets."
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Set to true to enforce block public access settings."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm. AES256 or aws:kms."
  type        = string
  default     = "AES256"
}