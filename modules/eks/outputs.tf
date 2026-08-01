output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "ebs_csi_addon_name" {
  description = "Name of the EBS CSI EKS add-on"
  value       = aws_eks_addon.ebs_csi.addon_name
}

output "ebs_csi_iam_role_arn" {
  description = "IAM role ARN used by the EBS CSI driver"
  value       = aws_iam_role.ebs_csi.arn
}

output "oidc_provider" {
  description = "OIDC provider URL without the https prefix"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = module.eks.oidc_provider_arn
}
