output "namespace" {
  value = helm_release.jenkins.namespace
}

output "release_name" {
  value = helm_release.jenkins.name
}

output "jenkins_password_cmd" {
  value = "kubectl -n jenkins get secret jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d"
}

output "jenkins_url_cmd" {
  value = "kubectl -n jenkins get svc jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "jenkins_iam_role_arn" {
  description = "IAM role ARN used by the Jenkins Kubernetes ServiceAccount"
  value       = aws_iam_role.jenkins.arn
}

output "ecr_docker_config_secret_name" {
  description = "Kubernetes Secret used by Kaniko for ECR authentication"
  value       = kubernetes_secret_v1.ecr_docker_config.metadata[0].name
}
