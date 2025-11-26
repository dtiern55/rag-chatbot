resource "aws_dynamodb_table" "metadata" {
  name           = "${var.repo_name}-metadata-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  
  # Primary Key: Composite (document_id + chunk_index)
  hash_key       = "document_id"      # Groups chunks by document
  range_key      = "chunk_index"      # Orders chunks within a document
  
  # Define attributes that are used in keys (primary or GSI)
  attribute {
    name = "document_id"
    type = "S"  # String
  }
  
  attribute {
    name = "chunk_index"
    type = "N"  # Number
  }
  
  attribute {
    name = "chunk_id"
    type = "S"  # String - unique identifier for each chunk
  }
  
  # Global Secondary Index - allows lookup by chunk_id directly
  global_secondary_index {
    name            = "chunk_id-index"
    hash_key        = "chunk_id"
    projection_type = "ALL"  # Include all attributes in the index
  }
  
  # Optional: Enable point-in-time recovery (good for production)
  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }
  
  tags = {
    Name        = "${var.repo_name}-metadata-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
