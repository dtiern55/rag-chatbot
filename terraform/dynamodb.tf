resource "aws_dynamodb_table" "metadata" {
  name           = "${var.repo_name}-metadata-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  stream_enabled = false

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.repo_name}-metadata-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}