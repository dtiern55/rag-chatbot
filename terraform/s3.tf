locals {
  input_bucket_name  = "${var.bucket_prefix}-${var.environment}-input"
  output_bucket_name = "${var.bucket_prefix}-${var.environment}-output"
}

resource "aws_s3_bucket" "input" {
  bucket        = local.input_bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name        = local.input_bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Enable versioning on input bucket
resource "aws_s3_bucket_versioning" "input" {
  bucket = aws_s3_bucket.input.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption on input bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "input" {
  bucket = aws_s3_bucket.input.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle rule to expire objects in input bucket after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "input" {
  bucket = aws_s3_bucket.input.id

  rule {
    id     = "default-expiration"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "input_block" {
  bucket = aws_s3_bucket.input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "output" {
  bucket = local.output_bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name        = local.output_bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Enable versioning on output bucket
resource "aws_s3_bucket_versioning" "output" {
  bucket = aws_s3_bucket.output.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption on output bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "output" {
  bucket = aws_s3_bucket.output.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle rule to expire objects in output bucket after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "output" {
  bucket = aws_s3_bucket.output.id

  rule {
    id     = "default-expiration"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}




resource "aws_s3_bucket_public_access_block" "output_block" {
  bucket = aws_s3_bucket.output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "input_bucket" {
  description = "Name of the input S3 bucket"
  value       = aws_s3_bucket.input.bucket
}

output "output_bucket" {
  description = "Name of the output S3 bucket"
  value       = aws_s3_bucket.output.bucket
}

