variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "hash_key_name" {
  description = "Name of the hash key attribute (Partition Key)."
  type        = string
}

variable "hash_key_type" {
  description = "Type of the hash key attribute (S=String, N=Number, B=Binary)."
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "Controls how read/write throughput are managed. PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST" # Good default for state locking
}

variable "tags" {
  description = "A map of tags to assign to the table."
  type        = map(string)
  default     = {}
}