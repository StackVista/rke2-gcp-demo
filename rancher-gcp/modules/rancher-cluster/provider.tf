terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "5.4.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
  }
  required_version = ">= 1.0.0"
}
