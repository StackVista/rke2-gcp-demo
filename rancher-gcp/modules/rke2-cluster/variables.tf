variable "name_prefix" {}

variable "master_count" {
  default = 1
}
variable "worker_count" {
  default = 1
}

variable "vpc_name" {}
variable "subnetwork_name" {}

variable "username" {}
variable "ssh_key" {}
variable "ssh_private_key" {}
variable "image_family" {
  default = "sles-15"
}

variable "image_project" {
  default = "suse-cloud"
}

variable "rancher_tags" {
  default = ["rancher-server"]
}
