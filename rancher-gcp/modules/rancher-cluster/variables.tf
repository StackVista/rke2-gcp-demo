variable "name_prefix" {
}

variable "home_ips" {
  type = list(string)
}

variable "image_family" {
  default = "sles-15"
}

variable "image_project" {
  default = "suse-cloud"
}

variable "vpc_name" {}
variable "subnetwork_name" {}
variable "subnet_cidr" {}
variable "username" {}

variable "ssh_key" {
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}

variable "rancher_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
  default     = "v1.26.10+k3s2"
}

variable "machine_type" {
  default = "n1-standard-2"
}
