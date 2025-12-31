# IAM role for FastAPI pod (IRSA - IAM Roles for Service Accounts)
module "fastapi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.repo_name}-fastapi-role-${var.environment}"

  role_policy_arns = {
    policy = aws_iam_policy.fastapi_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["rag-chatbot:fastapi"]
    }
  }

  tags = {
    Name        = "${var.repo_name}-fastapi-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Policy for FastAPI to access DynamoDB and Bedrock
resource "aws_iam_policy" "fastapi_policy" {
  name = "${var.repo_name}-fastapi-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.metadata.arn
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.repo_name}-fastapi-policy"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

output "fastapi_service_account_role_arn" {
  description = "ARN of IAM role for FastAPI service account"
  value       = module.fastapi_irsa.iam_role_arn
}