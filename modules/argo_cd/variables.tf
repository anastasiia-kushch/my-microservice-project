variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "7.7.16"
}
