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
