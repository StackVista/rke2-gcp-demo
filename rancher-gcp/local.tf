locals {
  rancher_host_name = join(".", ["rancher", module.rancher-cluster.rancher_public_ip, "sslip.io"])
  rancher_url       = "https://${local.rancher_host_name}"
  master_tags       = ["rke2-master"]
  node_tags         = ["rke2-node"]
}
