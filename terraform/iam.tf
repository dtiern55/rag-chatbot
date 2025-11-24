# Lambda execution role
resource "aws_iam_role" "lambda_exec" {
  name = "${var.repo_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]

  })

  tags = {
    Name        = "${var.repo_name}-lambda-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IAM role for Lambda execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 input access
resource "aws_iam_role_policy" "lambda_s3_input_access" {
  name = "s3-input-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.input.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.input.arn}/*"
        ]
      }
    ]
  })
}

# S3 output access
resource "aws_iam_role_policy" "lambda_s3_output_access" {
  name = "s3-output-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.output.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.input.arn}/*"
        ]
      }
    ]
  })
}

# Bedrock access for embeddings and Claude
resource "aws_iam_role_policy" "lambda_bedrock_access" {
  name = "bedrock-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1",
          "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-*"
        ]
      }
    ]
  })
}

# DynamoDB access for metadata storage
resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "dynamodb-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.metadata.arn
      }
    ]
  })
}
