# Data sources
data "aws_caller_identity" "current" {}

# IAM role for Step Functions
resource "aws_iam_role" "stepfunctions_exec" {
  name = "${var.repo_name}-stepfunctions-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# Policy to invoke Lambdas
resource "aws_iam_role_policy" "stepfunctions_lambda_invoke" {
  name = "lambda-invoke"
  role = aws_iam_role.stepfunctions_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.repo_name}-*"
      }
    ]
  })
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "document_processor" {
  name     = "${var.repo_name}-document-processor-${var.environment}"
  role_arn = aws_iam_role.stepfunctions_exec.arn

  definition = jsonencode({
    Comment = "RAG Document Processing State Machine"
    StartAt = "ExtractText"
    States = {
      ExtractText = {
        Type     = "Task"
        Resource = aws_lambda_function.text_extractor.arn
        Next     = "ChunkText"
        Retry = [
          {
            ErrorEquals     = ["States.ALL"]
            IntervalSeconds = 2
            MaxAttempts     = 0
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "ProcessingFailed"
          }
        ]
      }
      ChunkText = {
        Type     = "Task"
        Resource = aws_lambda_function.text_chunker.arn
        Next     = "EmbeddingGenerator"
        Retry = [
          {
            ErrorEquals     = ["States.ALL"]
            IntervalSeconds = 2
            MaxAttempts     = 0
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "ProcessingFailed"
          }
        ]
      }
      EmbeddingGenerator = {
        Type     = "Task"
        Resource = aws_lambda_function.embedding_generator.arn
        Next     = "StoreData"
        Retry = [
          {
            ErrorEquals     = ["States.ALL"]
            IntervalSeconds = 2
            MaxAttempts     = 0
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "ProcessingFailed"
          }
        ]
      }
      StoreData = {
        Type     = "Task"
        Resource = aws_lambda_function.data_storer.arn
        Next      = "ProcessingComplete"
        Retry = [
          {
            ErrorEquals     = ["States.ALL"]
            IntervalSeconds = 2
            MaxAttempts     = 0
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "ProcessingFailed"
          }
        ]
      }
      ProcessingComplete = {
        Type = "Succeed"
      }
      ProcessingFailed = {
        Type  = "Fail"
        Error = "ProcessingError"
        Cause = "Document processing failed"
      }
    }
  })

  tags = {
    Name        = "${var.repo_name}-document-processor-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
