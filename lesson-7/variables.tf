variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "bucket_name" {
  type    = string
  default = "anastasiia-kushch-tf-state-2026"
}

variable "dynamodb_table_name" {
  type    = string
  default = "terraform-locks"
}

variable "vpc_name" {
  type    = string
  default = "lesson-5-vpc"
}

variable "ecr_name" {
  type    = string
  default = "lesson-5-ecr"
}
