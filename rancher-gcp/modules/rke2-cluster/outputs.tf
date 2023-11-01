output "master_addresses" {
  value = google_compute_instance.rke2-master[*].network_interface[0].access_config[0].nat_ip
}

output "worker_addresses" {
  value = google_compute_instance.rke2-worker[*].network_interface[0].access_config[0].nat_ip
}

output "master_loadbalancer_ip" {
  value = google_compute_address.rke2-lb-ip.address
}

output "worker_loadbalancer_ip" {
  value = google_compute_address.rke2-lb-ip-workers.address
}

output "cluster_name" {
  value = var.name_prefix
}

output "rke2_cluster_id" {
  value     = rancher2_cluster_v2.rke2-cluster.cluster_registration_token[0].cluster_id
  sensitive = true
}

output "kubeconfig" {
  value = local_file.kubeconfig_yaml.content
}

output "kubeconfig_filename" {
  value = local_file.kubeconfig_yaml.filename
}
