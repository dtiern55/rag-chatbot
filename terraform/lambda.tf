# Lambda 1: Text Extractor
resource "aws_lambda_function" "text_extractor" {
  function_name = "${var.repo_name}-text-extractor-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  
  filename         = data.archive_file.text_extractor.output_path
  source_code_hash = data.archive_file.text_extractor.output_base64sha256
  
  timeout = 60
  memory_size = 256
}

# Zip Text Extractor Lambda code
data "archive_file" "text_extractor" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/text_extractor"
  output_path = "${path.module}/../.terraform/lambdas/text_extractor.zip"
}

# Lambda 2: Text Chunker
resource "aws_lambda_function" "text_chunker" {
  function_name = "${var.repo_name}-text-chunker-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  
  filename         = data.archive_file.text_chunker.output_path
  source_code_hash = data.archive_file.text_chunker.output_base64sha256
  
  timeout = 60
  memory_size = 256
}

# Zip Text Chunker Lambda code
data "archive_file" "text_chunker" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/text_chunker"
  output_path = "${path.module}/../.terraform/lambdas/text_chunker.zip"
}

# Lambda 3: Embedding Generator
resource "aws_lambda_function" "embedding_generator" {
  function_name = "${var.repo_name}-embedding-generator-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  
  filename         = data.archive_file.embedding_generator.output_path
  source_code_hash = data.archive_file.embedding_generator.output_base64sha256
  
  timeout = 60
  memory_size = 256
}

# Zip Embedding Generator Lambda code
data "archive_file" "embedding_generator" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/embedding_generator"
  output_path = "${path.module}/../.terraform/lambdas/embedding_generator.zip"
}

# Lambda 4: Data Storer
resource "aws_lambda_function" "data_storer" {
  function_name = "${var.repo_name}-data-storer-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  
  filename         = data.archive_file.data_storer.output_path
  source_code_hash = data.archive_file.data_storer.output_base64sha256
  
  timeout = 60
  memory_size = 256
}

# Zip Data Storer Lambda code
data "archive_file" "data_storer" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/data_storer"
  output_path = "${path.module}/../.terraform/lambdas/data_storer.zip"
}