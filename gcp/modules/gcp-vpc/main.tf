resource "google_compute_network" "gcp-vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = "false"
}

# Create a Subnet
resource "google_compute_subnetwork" "gcp-subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = "10.10.0.0/24"
  network       = google_compute_network.gcp-vpc.name
  region        = var.region
}

## Create Cloud Router
resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  network = google_compute_network.gcp-vpc.name
}

## Create Nat Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name_prefix}-router-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
