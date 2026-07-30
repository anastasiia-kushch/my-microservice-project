output "namespace" {
  value = helm_release.jenkins.namespace
}

output "release_name" {
  value = helm_release.jenkins.name
}
