# ECR repository for FastAPI image
resource "aws_ecr_repository" "fastapi" {
  name                 = "${var.repo_name}-fastapi-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.repo_name}-fastapi-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.fastapi.repository_url
}