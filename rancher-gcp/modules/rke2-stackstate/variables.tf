
variable "sts_api_key" {
  description = "The API key for connecting to the StackState Receiver API"
}

variable "sts_url" {
  description = "The URL for connecting to the StackState Receiver API"
}

variable "sts_cluster_name" {
  description = "The name of the cluster that its registered with in StackState"
}

variable "rke2_cluster_id" {
  description = "The ID/Name of the RKE2 cluster to install the StackState Agent on"
}
