
resource "google_compute_firewall" "allow-k8s-internal" {
  name    = "${var.name_prefix}-allow-k8s-internal"
  network = var.vpc_name

  allow {
    protocol = "all"
  }

  # allow {
  #   protocol = "icmp"
  # }
  # allow {
  #   protocol = "tcp"
  #   ports    = ["80", "443", "6443", "8443", "9345", "10250", "10251", "10252", "10254"]
  # }

  # allow {
  #   protocol = "udp"
  #   ports    = ["8472"]
  # }

  source_tags = ["rke2-master", "rke2-worker", "rancher-master"]
}

resource "google_compute_firewall" "allow-k8s" {
  name    = "${var.name_prefix}-allow-k8s"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  source_ranges = var.home_ips
  target_tags   = var.master_tags
}

# Create a firewall to allow SSH connection from the specified source range
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.name_prefix}-allow-ssh"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = concat(["35.235.240.0/20"], var.home_ips)
  target_tags   = var.node_tags
}

resource "google_compute_firewall" "allow-dns" {
  name    = "${var.name_prefix}-allow-dns"
  network = var.vpc_name

  source_tags = ["rke2-master", "rke2-worker", "rancher-master"]
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
}

resource "google_compute_firewall" "allow-health-check" {
  name    = "${var.name_prefix}-allow-health-check"
  network = var.vpc_name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}
