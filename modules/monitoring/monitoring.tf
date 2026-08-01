resource "helm_release" "monitoring" {
  name = var.release_name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  namespace        = var.namespace
  create_namespace = true

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        grafana_storage_size    = var.grafana_storage_size
        prometheus_storage_size = var.prometheus_storage_size
        prometheus_retention    = var.prometheus_retention
        grafana_service_type    = var.grafana_service_type
        enable_alertmanager     = var.enable_alertmanager
      }
    )
  ]

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  wait          = true
  wait_for_jobs = true
  timeout       = 900

  atomic          = true
  cleanup_on_fail = true
}
