locals {
  external_ip = google_compute_address.rancher_server_address.address
  internal_ip = google_compute_instance.rancher_server.network_interface.0.network_ip
}

resource "local_file" "kube_config_server_yaml" {
  filename        = format("%s/%s-%s", path.root, var.name_prefix, "rancher_kubeconfig.yaml")
  content         = ssh_resource.retrieve_config.result
  file_permission = "0600"
}
