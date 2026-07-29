variable "ecr_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "scan_on_push" {
  type        = bool
  description = "Indicates whether images are scanned after being pushed to the repository"
  default     = true
}
