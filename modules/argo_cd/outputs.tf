output "namespace" {
  value = helm_release.argocd.namespace
}

output "release_name" {
  value = helm_release.argocd.name
}

output "argocd_password_cmd" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_url_cmd" {
  value = "kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}
