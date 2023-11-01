output "vpc_name" {
  value = google_compute_network.gcp-vpc.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.gcp-subnet.name
}

output "subnet_cidr" {
  value = google_compute_subnetwork.gcp-subnet.ip_cidr_range
}
