terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }

    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
  }
}

