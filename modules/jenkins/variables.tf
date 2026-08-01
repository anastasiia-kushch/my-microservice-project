variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "namespace" {
  type    = string
  default = "jenkins"
}

variable "chart_version" {
  type    = string
  default = "5.7.26"
}

variable "oidc_provider" {
  description = "EKS OIDC provider URL without the https prefix"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository accessible by Jenkins"
  type        = string
}
