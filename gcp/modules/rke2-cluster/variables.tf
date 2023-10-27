variable "name_prefix" {}

variable "master_count" {
  default = 1
}
variable "agent_count" {
  default = 1
}

variable "vpc_name" {}
variable "subnetwork_name" {}

variable "instance_image" {
  default = "ubuntu-os-cloud/ubuntu-minimal-2204-jammy-v20231025"
}

variable "username" {}
variable "ssh_key" {}
