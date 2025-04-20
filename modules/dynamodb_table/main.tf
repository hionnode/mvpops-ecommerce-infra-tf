resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key_name

  # Define the hash key attribute schema element
  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  # Enable encryption and point-in-time recovery (good practice for state lock tables)
  server_side_encryption {
    enabled = true
  }
  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags
}