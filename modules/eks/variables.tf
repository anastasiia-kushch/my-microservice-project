variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "lesson-7-eks"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from the VPC module"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets from the VPC module"
}
