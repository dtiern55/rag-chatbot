# Lambda ARNs
output "text_extractor_arn" {
  description = "ARN of the text extractor Lambda"
  value       = aws_lambda_function.text_extractor.arn
}

output "text_chunker_arn" {
  description = "ARN of the text chunker Lambda"
  value       = aws_lambda_function.text_chunker.arn
}

output "embedding_generator_arn" {
  description = "ARN of the embedding generator Lambda"
  value       = aws_lambda_function.embedding_generator.arn
}

output "data_storer_arn" {
  description = "ARN of the data storer Lambda"
  value       = aws_lambda_function.data_storer.arn
}

# DynamoDB
output "dynamodb_table_name" {
  description = "Name of the DynamoDB metadata table"
  value       = aws_dynamodb_table.metadata.name
}

# S3 Buckets
output "input_bucket_name" {
  description = "Name of the input S3 bucket"
  value       = aws_s3_bucket.input.bucket
}

output "output_bucket_name" {
  description = "Name of the output S3 bucket"
  value       = aws_s3_bucket.output.bucket
}

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.document_processor.arn
}
