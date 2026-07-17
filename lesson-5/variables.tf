variable "aws_region" {
  type        = string
  description = "AWS deployment region"
  default     = "us-west-2"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique name for the S3 state bucket"
  default     = "anastasiia-kushch-tf-state-2026"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB lock table"
  default     = "terraform-locks"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
  default     = "lesson-5-vpc"
}

variable "ecr_name" {
  type        = string
  description = "Name of the ECR Repository"
  default     = "lesson-5-ecr"
}
