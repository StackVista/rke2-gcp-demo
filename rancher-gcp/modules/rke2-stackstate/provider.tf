terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}
