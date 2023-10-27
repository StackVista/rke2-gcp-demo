variable "gcp_project" {
}

variable "gcp_region" {
  description = "The GCP region to deploy to"
  default     = "europe-west4"
}

variable "gcp_zone" {
  description = "The GCP zone to deploy to"
  default     = "europe-west4-a"
}

variable "name_prefix" {
  default = "rke2-demo-cluster"
}

variable "cluster_count" {
  default = 2
}

variable "master_count" {
  default = 1
}

variable "username" {
  description = "The username to use for SSH access to the cluster"
}

variable "iam_user" {
  description = "The email address of the user to grant IAP SSH access to"
}

variable "home_ip" {
  description = "Your home IP address, used to allow SSH access to the cluster"
}

variable "sts_api_key" {
  description = "The API key for connecting to the StackState Receiver API"
}

variable "sts_url" {
  description = "The URL for connecting to the StackState Receiver API"
}

variable "ssh_key_file" {
  description = "The path to the SSH key file to use for SSH access to the cluster"
  default     = "~/.ssh/id_rsa.pub"
}
