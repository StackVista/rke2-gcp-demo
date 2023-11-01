variable "name_prefix" {
  default = "rke2-demo-cluster"
}

variable "home_ips" {
  default = []
}

variable "master_tags" {
  default = ["rke2-master"]
}

variable "node_tags" {
  default = ["rke2-node"]
}

variable "vpc_name" {
}

variable "subnet_cidr" {
}
