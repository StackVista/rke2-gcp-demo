# Create a VPC
module "rke2-vpc" {
  source      = "./modules/gcp-vpc"
  name_prefix = "rke2-vpc"
  gcp_project = var.gcp_project
  region      = var.gcp_region
}

module "rke2-cluster" {
  count           = var.cluster_count
  source          = "./modules/rke2-cluster"
  name_prefix     = "rke2-cluster-${count.index}"
  vpc_name        = module.rke2-vpc.vpc_name
  subnetwork_name = module.rke2-vpc.subnetwork_name
  master_count    = var.master_count
  ssh_key         = file(var.ssh_key_file)
  username        = var.username
}

## Create IAP SSH permissions for your test instance
resource "google_project_iam_member" "project1" {
  project = var.gcp_project
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${var.iam_user}"
}

resource "google_compute_firewall" "k8s-internal" {
  name    = "${var.name_prefix}-allow-k8s-internal"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6443", "8443", "9345", "10250", "10251", "10252", "10254"]
  }

  allow {
    protocol = "udp"
    ports    = ["8472"]
  }

  source_ranges = [module.rke2-vpc.subnet_cidr]
}

resource "google_compute_firewall" "k8s-rules" {
  name    = "${var.name_prefix}-allow-k8s"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  source_ranges = [var.home_ip]
  target_tags   = ["rke2-master"]
}

# Create a firewall to allow SSH connection from the specified source range
resource "google_compute_firewall" "ssh-rules" {
  name    = "${var.name_prefix}-allow-ssh"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20", var.home_ip]
  target_tags   = ["rke2-node"]
}

resource "google_compute_firewall" "allow-dns" {
  name    = "${var.name_prefix}-allow-dns"
  network = module.rke2-vpc.vpc_name

  source_ranges = ["0.0.0.0"]

  allow {
    protocol = "tcp"
    ports    = ["53", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
}

resource "google_compute_firewall" "allow-health-check" {
  name    = "${var.name_prefix}-allow-health-check"
  network = module.rke2-vpc.vpc_name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}
