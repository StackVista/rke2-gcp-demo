output "master_addresses" {
  value = google_compute_instance.rke2-master[*].network_interface[0].access_config[0].nat_ip
}

output "loadbalancer_ip" {
  value = google_compute_address.rke2-lb-ip.address
}

output "cluster_name" {
  value = var.name_prefix
}
