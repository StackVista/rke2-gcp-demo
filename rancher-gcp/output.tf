output "rancher" {
  value     = module.rancher-deploy
  sensitive = true
}

output "rancher-cluster" {
  value = module.rancher-cluster
}

output "rke2-clusters" {
  value     = module.rke2-cluster
  sensitive = true
}

output "otel-cluster" {
  value     = module.otel-cluster
  sensitive = true
}
output "rancher-url" {
  value = local.rancher_url
}
