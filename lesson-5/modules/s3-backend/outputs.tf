output "s3_bucket_name" {
  value       = aws_s3_bucket.backend.id
  description = "The name of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.locks.name
  description = "The name of the DynamoDB table"
}
