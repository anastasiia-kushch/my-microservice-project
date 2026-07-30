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
