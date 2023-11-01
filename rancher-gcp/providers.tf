terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Rancher2 administration provider
provider "rancher2" {
  alias = "admin"

  api_url  = local.rancher_url
  insecure = true
  # ca_certs  = data.kubernetes_secret.rancher_cert.data["ca.crt"]
  token_key = module.rancher-deploy.rancher_bootstrap_token
  timeout   = "300s"
}

provider "helm" {
  kubernetes {
    config_path = module.rancher-cluster.rancher_kubeconfig_filename
  }
}

# Rancher2 bootstrapping provider
provider "rancher2" {
  alias = "bootstrap"

  api_url  = local.rancher_url
  insecure = true
  # ca_certs  = data.kubernetes_secret.rancher_cert.data["ca.crt"]
  bootstrap = true
}
