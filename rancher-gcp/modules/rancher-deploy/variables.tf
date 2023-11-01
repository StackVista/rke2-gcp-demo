# Variables for rancher deploy module

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
  default     = "1.11.0"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format v0.0.0)"
  default     = "2.7.6"
}

# Required
variable "rancher_server_dns" {
  type        = string
  description = "DNS host name of the Rancher server"
}

# Required
variable "admin_password" {
  type        = string
  description = "Admin password to use for Rancher server bootstrap, min. 12 characters"
}

variable "rancher_helm_repository" {
  type        = string
  description = "The helm repository, where the Rancher helm chart is installed from"
  default     = "https://releases.rancher.com/server-charts/latest"
}

# variable "workload_kubernetes_version" {
#   type        = string
#   description = "Kubernetes version to use for managed workload cluster"
#   default     = "v1.24.14+rke2r1"
# }

# # Required
# variable "workload_cluster_name" {
#   type        = string
#   description = "Name for created custom workload cluster"
# }

