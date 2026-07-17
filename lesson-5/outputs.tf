output "s3_bucket_name" {
  value       = module.s3_backend.s3_bucket_name
  description = "Name of the S3 bucket used for the Terraform backend"
}

output "dynamodb_table_name" {
  value       = module.s3_backend.dynamodb_table_name
  description = "Name of the DynamoDB table used for state locking"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the created VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of the private subnets"
}

output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "The ID of the Internet Gateway"
}

output "nat_gateway_id" {
  value       = module.vpc.nat_gateway_id
  description = "The ID of the NAT Gateway"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "The URL of the ECR repository"
}
