variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "repo_name" {
  type    = string
  default = "rag-chatbot"
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix used for S3 bucket names"
  type        = string
  default     = "rag-chatbot"
}

variable "force_destroy" {
  description = "Whether to force destroy S3 buckets (useful for CI)"
  type        = bool
  default     = false
}