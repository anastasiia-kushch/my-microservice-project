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

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must contain at least 8 characters."
  }
}

variable "grafana_admin_password" {
  description = "Administrator password for Grafana"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.grafana_admin_password) >= 8
    error_message = "Grafana password must contain at least 8 characters."
  }
}
