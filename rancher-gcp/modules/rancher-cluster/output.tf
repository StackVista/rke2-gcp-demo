output "rancher_public_ip" {
  value = google_compute_address.rancher_server_address.address
}

output "rancher_private_ip" {
  value = google_compute_instance.rancher_server.network_interface.0.network_ip
}

output "rancher_kubeconfig" {
  value = local_file.kube_config_server_yaml.content
}

output "rancher_kubeconfig_filename" {
  value = local_file.kube_config_server_yaml.filename
}

output "cluster_name" {
  value = "${var.name_prefix}-rancher"
}
