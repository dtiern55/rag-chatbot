variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "bucket_prefix" {
  description = "Prefix used for S3 bucket names"
  type        = string
  default     = "pii-redaction-pipeline"
}

variable "force_destroy" {
  description = "Whether to force destroy S3 buckets (useful for CI)"
  type        = bool
  default     = false
}