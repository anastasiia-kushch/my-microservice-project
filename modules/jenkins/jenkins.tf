resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "ecr_docker_config" {
  metadata {
    name      = "ecr-docker-config"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      credsStore = "ecr-login"
    })
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version

  namespace        = kubernetes_namespace_v1.jenkins.metadata[0].name
  create_namespace = false

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        jenkins_role_arn = aws_iam_role.jenkins.arn
      }
    )
  ]

  wait          = true
  wait_for_jobs = true
  timeout       = 1200

  atomic          = false
  cleanup_on_fail = false

  depends_on = [
    aws_iam_role_policy_attachment.jenkins_ecr,
    kubernetes_secret_v1.ecr_docker_config
  ]
}
