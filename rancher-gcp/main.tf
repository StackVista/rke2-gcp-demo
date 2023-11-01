module "rke2-vpc" {
  source      = "./modules/gcp-vpc"
  name_prefix = var.name_prefix
  gcp_project = var.gcp_project
  region      = var.gcp_region
}

module "networking" {
  source      = "./modules/networking"
  name_prefix = var.name_prefix
  home_ips    = var.home_ips
  master_tags = local.master_tags
  node_tags   = local.node_tags
  vpc_name    = module.rke2-vpc.vpc_name
  subnet_cidr = module.rke2-vpc.subnet_cidr
}

module "rancher-cluster" {
  source          = "./modules/rancher-cluster"
  username        = var.username
  subnetwork_name = module.rke2-vpc.subnetwork_name
  subnet_cidr     = module.rke2-vpc.subnet_cidr
  vpc_name        = module.rke2-vpc.vpc_name
  name_prefix     = var.name_prefix
  ssh_key         = tls_private_key.ssh_key.public_key_openssh
  ssh_private_key = tls_private_key.ssh_key.private_key_pem
  home_ips        = var.home_ips
}

module "rancher-deploy" {
  depends_on = [module.rancher-cluster, module.networking]
  source     = "./modules/rancher-deploy"

  rancher_server_dns = local.rancher_host_name
  admin_password     = var.rancher_server_admin_password
  providers = {
    rancher2 = rancher2.bootstrap
  }
}

module "rke2-cluster" {
  count           = var.cluster_count
  source          = "./modules/rke2-cluster"
  name_prefix     = "${var.name_prefix}-cluster-${count.index}"
  vpc_name        = module.rke2-vpc.vpc_name
  subnetwork_name = module.rke2-vpc.subnetwork_name
  master_count    = var.master_count
  worker_count    = var.worker_count
  ssh_key         = tls_private_key.ssh_key.public_key_openssh
  ssh_private_key = tls_private_key.ssh_key.private_key_pem
  username        = var.username
  machine_type    = var.machine_type
  providers = {
    rancher2 = rancher2.admin
  }
}

module "rke2-stackstate" {
  count            = var.cluster_count
  source           = "./modules/rke2-stackstate"
  sts_api_key      = var.sts_api_key
  sts_url          = var.sts_url
  sts_cluster_name = module.rke2-cluster[count.index].cluster_name
  rke2_cluster_id  = module.rke2-cluster[count.index].rke2_cluster_id
  providers = {
    rancher2 = rancher2.admin
  }
}

## Create IAP SSH permissions for your test instance
resource "google_project_iam_member" "project1" {
  project = var.gcp_project
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${var.iam_user}"
}
