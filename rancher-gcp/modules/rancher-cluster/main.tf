resource "google_compute_address" "rancher_server_address" {
  name = "rancher-server-ipv4-address"
}
resource "google_compute_firewall" "rancher-allow" {
  name    = "${var.name_prefix}-rancher-allow"
  network = var.vpc_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  # source_ranges = concat(["35.235.240.0/20"], var.home_ips, [var.subnet_cidr])
  target_tags = ["rancher-server"]
}

resource "google_compute_firewall" "rancher-allow-internal" {
  name    = "${var.name_prefix}-rancher-allow-internal"
  network = var.vpc_name

  allow {
    protocol = "all"
  }

  source_ranges = [google_compute_address.rancher_server_address.address]
}

# GCP Compute Instance for creating a single node RKE cluster and installing the Rancher server
resource "google_compute_instance" "rancher_server" {
  name           = "${var.name_prefix}-rancher-server"
  machine_type   = "n1-standard-2"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.sles.self_link
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {
      nat_ip = google_compute_address.rancher_server_address.address
    }
  }

  tags = ["rancher-server"]

  metadata = {
    ssh-keys       = "${var.username}:${var.ssh_key}"
    enable-oslogin = "FALSE"
  }
}

resource "ssh_resource" "install_k3s" {
  host = local.external_ip
  commands = [
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server --node-external-ip ${local.external_ip} --node-ip ${local.internal_ip}\" INSTALL_K3S_VERSION=${var.rancher_kubernetes_version} sh -'"
  ]
  user        = var.username
  private_key = var.ssh_private_key
}

resource "ssh_resource" "retrieve_config" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  host = local.external_ip
  commands = [
    "sudo sed \"s/127.0.0.1/${local.external_ip}/g\" /etc/rancher/k3s/k3s.yaml"
  ]
  user        = var.username
  private_key = var.ssh_private_key
}
