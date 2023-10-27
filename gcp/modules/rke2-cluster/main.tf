resource "google_compute_address" "rke2-lb-ip" {
  name = "${var.name_prefix}-loadbalancer-ip"
}

resource "google_compute_forwarding_rule" "rke2-lb" {
  name        = "${var.name_prefix}-loadbalancer"
  ip_address  = google_compute_address.rke2-lb-ip.address
  target      = google_compute_target_pool.rke2-masters.self_link
  port_range  = "6443"
  ip_protocol = "TCP"
}

resource "google_compute_target_pool" "rke2-masters" {
  name = "${var.name_prefix}-masters"
  instances = [
    for instance in google_compute_instance.rke2-master : instance.self_link
  ]
  session_affinity = "CLIENT_IP"
}

resource "random_uuid" "rke2-token" {
}

resource "google_compute_instance" "rke2-master" {
  count        = var.master_count
  name         = "${var.name_prefix}-master-${count.index}"
  machine_type = "e2-medium"
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  tags = ["rke2-node", "rke2-master"]

  metadata = {
    ssh-keys = "${var.username}:${var.ssh_key}"
    user-data = templatefile("${path.module}/templates/master.yaml", {
      external_ip = google_compute_address.rke2-lb-ip.address
      ssh_key     = var.ssh_key
      username    = var.username
      token       = random_uuid.rke2-token.result
      name_prefix = var.name_prefix
    })
  }

  boot_disk {
    initialize_params {
      size  = 50
      image = var.instance_image
    }
  }
  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
}

resource "google_compute_instance" "rke2-agent" {
  count        = var.agent_count
  name         = "${var.name_prefix}-agent-${count.index}"
  machine_type = "e2-medium"
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.username}:${var.ssh_key}"
    user-data = templatefile("${path.module}/templates/agent.yaml", {
      ssh_key     = var.ssh_key
      username    = var.username
      token       = random_uuid.rke2-token.result
      server_ip   = google_compute_instance.rke2-master[0].network_interface[0].network_ip
      name_prefix = var.name_prefix
    })
  }

  tags = ["rke2-node", "rke2-agent"]

  boot_disk {
    initialize_params {
      size  = 50
      image = var.instance_image
    }
  }
  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
}
