variable "namespace" {
  description = "Kubernetes namespace for Prometheus and Grafana"
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "87.12.1"
}

variable "grafana_admin_password" {
  description = "Administrator password for Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_storage_size" {
  description = "Persistent volume size for Grafana"
  type        = string
  default     = "5Gi"
}

variable "prometheus_storage_size" {
  description = "Persistent volume size for Prometheus"
  type        = string
  default     = "10Gi"
}

variable "prometheus_retention" {
  description = "Prometheus metrics retention period"
  type        = string
  default     = "7d"
}

variable "grafana_service_type" {
  description = "Kubernetes service type for Grafana"
  type        = string
  default     = "ClusterIP"

  validation {
    condition = contains(
      ["ClusterIP", "LoadBalancer", "NodePort"],
      var.grafana_service_type
    )

    error_message = "grafana_service_type must be ClusterIP, LoadBalancer or NodePort."
  }
}

variable "enable_alertmanager" {
  description = "Enable Alertmanager deployment"
  type        = bool
  default     = true
}
