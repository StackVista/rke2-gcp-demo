terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }
  }
  required_version = ">= 1.0.0"
}
