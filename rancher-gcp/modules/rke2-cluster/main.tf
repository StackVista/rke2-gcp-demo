resource "google_compute_address" "rke2-lb-ip-masters" {
  name = "${var.name_prefix}-loadbalancer-ip-masters"
}
resource "google_compute_address" "rke2-lb-ip-workers" {
  name = "${var.name_prefix}-loadbalancer-ip-workers"
}

resource "google_compute_firewall" "allow-to-rancher" {
  name    = "${var.name_prefix}-allow-to-rancher"
  network = var.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "6443"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = concat(google_compute_instance.rke2-worker[*].network_interface[0].access_config[0].nat_ip, google_compute_instance.rke2-master[*].network_interface[0].access_config[0].nat_ip)
  target_tags   = var.rancher_tags
}

resource "google_service_account" "rke2-sa" {
  account_id   = "${var.name_prefix}-sa"
  display_name = "Service Account for provisioned RKE2 cluster"
}

resource "google_compute_forwarding_rule" "rke2-lb-masters" {
  name        = "${var.name_prefix}-loadbalancer-masters"
  ip_address  = google_compute_address.rke2-lb-ip-masters.address
  target      = google_compute_target_pool.rke2-masters.self_link
  port_range  = "80-6443"
  ip_protocol = "TCP"
}

resource "google_compute_forwarding_rule" "rke2-lb-workers" {
  name        = "${var.name_prefix}-loadbalancer-workers"
  ip_address  = google_compute_address.rke2-lb-ip-workers.address
  target      = google_compute_target_pool.rke2-workers.self_link
  port_range  = "80-443"
  ip_protocol = "TCP"
}

resource "google_compute_http_health_check" "rke2-health-check" {
  name                = "${var.name_prefix}-kubernetes"
  request_path        = "/healthz"
  description         = "The health check for Kubernetes API server"
  port                = 10256
  healthy_threshold   = 1
  unhealthy_threshold = 3
}


resource "google_compute_target_pool" "rke2-masters" {
  name             = "${var.name_prefix}-masters"
  instances        = google_compute_instance.rke2-master[*].self_link
  health_checks    = [google_compute_http_health_check.rke2-health-check.name]
  session_affinity = "CLIENT_IP"
}

resource "google_compute_target_pool" "rke2-workers" {
  name             = "${var.name_prefix}-workers"
  instances        = google_compute_instance.rke2-worker[*].self_link
  session_affinity = "CLIENT_IP"
}

resource "rancher2_cluster_v2" "rke2-cluster" {
  name               = var.name_prefix
  kubernetes_version = local.rke2_version
  rke_config {
    machine_global_config = templatefile("${path.module}/templates/rke2-config.yaml", {
      lb_ip_address = google_compute_address.rke2-lb-ip-masters.address
      fqdn          = "${google_compute_address.rke2-lb-ip-masters.address}.sslip.io"
    })
  }
}

resource "google_compute_instance" "rke2-master" {
  count          = var.master_count
  name           = "${var.name_prefix}-master-${count.index}"
  machine_type   = var.machine_type
  can_ip_forward = true
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  tags = ["rke2-node", "rke2-master"]

  metadata = {
    ssh-keys = "${var.username}:${var.ssh_key}"
    user-data = templatefile("${path.module}/templates/master.yaml", {
      ssh_key = var.ssh_key
    })
  }

  service_account {
    email = google_service_account.rke2-sa.email
    scopes = ["cloud-platform", "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }

  boot_disk {
    initialize_params {
      size  = 50
      image = data.google_compute_image.sles.self_link
    }
  }
  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
}

resource "ssh_resource" "register-master" {
  depends_on  = [rancher2_cluster_v2.rke2-cluster, google_compute_instance.rke2-master]
  count       = var.master_count
  host        = google_compute_instance.rke2-master[count.index].network_interface[0].access_config[0].nat_ip
  user        = var.username
  private_key = var.ssh_private_key
  commands = [
    "${rancher2_cluster_v2.rke2-cluster.cluster_registration_token[0].insecure_node_command} --address ${google_compute_instance.rke2-master[count.index].network_interface[0].access_config[0].nat_ip} --internal-address ${google_compute_instance.rke2-master[count.index].network_interface[0].network_ip} --etcd --controlplane"
  ]
}

resource "google_compute_instance" "rke2-worker" {
  count          = var.worker_count
  name           = "${var.name_prefix}-worker-${count.index}"
  machine_type   = var.machine_type
  can_ip_forward = true

  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.username}:${var.ssh_key}"
    user-data = templatefile("${path.module}/templates/worker.yaml", {
      ssh_key = var.ssh_key
    })
  }

  service_account {
    email = google_service_account.rke2-sa.email

    scopes = ["cloud-platform", "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }

  tags = ["rke2-node", "rke2-worker"]

  boot_disk {
    initialize_params {
      size  = 50
      image = data.google_compute_image.sles.self_link
    }
  }
  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
}

resource "ssh_resource" "register-worker" {
  depends_on  = [rancher2_cluster_v2.rke2-cluster, google_compute_instance.rke2-worker]
  count       = var.worker_count
  host        = google_compute_instance.rke2-worker[count.index].network_interface[0].access_config[0].nat_ip
  user        = var.username
  private_key = var.ssh_private_key
  commands = [
    "${rancher2_cluster_v2.rke2-cluster.cluster_registration_token[0].insecure_node_command} --address ${google_compute_instance.rke2-worker[count.index].network_interface[0].access_config[0].nat_ip} --internal-address ${google_compute_instance.rke2-worker[count.index].network_interface[0].network_ip} --worker"
  ]
}

resource "ssh_resource" "retrieve_kubeconfig" {
  depends_on = [
    ssh_resource.register-master
  ]
  host        = google_compute_instance.rke2-master[0].network_interface[0].access_config[0].nat_ip
  user        = var.username
  private_key = var.ssh_private_key
  commands = [
    "sudo sed \"s/127.0.0.1/${google_compute_address.rke2-lb-ip-masters.address}/g\" /etc/rancher/rke2/rke2.yaml"
  ]
}
