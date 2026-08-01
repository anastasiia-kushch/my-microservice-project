output "namespace" {
  description = "Namespace where monitoring components are installed"
  value       = helm_release.monitoring.namespace
}

output "release_name" {
  description = "Helm release name of kube-prometheus-stack"
  value       = helm_release.monitoring.name
}

output "grafana_port_forward_command" {
  description = "Command for accessing Grafana locally"
  value       = "kubectl port-forward svc/grafana 3000:80 -n ${var.namespace}"
}

output "prometheus_port_forward_command" {
  description = "Command for accessing Prometheus locally"
  value       = "kubectl port-forward svc/${var.release_name}-kube-prometheus-prometheus 9090:9090 -n ${var.namespace}"
}

output "grafana_username" {
  description = "Default Grafana administrator username"
  value       = "admin"
}
