# Outputs
output "rancher_bootstrap_token" {
  value       = rancher2_bootstrap.admin.token
  description = "Rancher bootstrap token"
  sensitive   = true
}
