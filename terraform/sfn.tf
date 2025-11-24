# Step Functions execution role
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

# Allow Step Functions to invoke Lambda
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

# Needed to get account ID
data "aws_caller_identity" "current" {}
