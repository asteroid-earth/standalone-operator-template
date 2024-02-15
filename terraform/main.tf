terraform {
  required_providers {
    teleport = {
      source  = "terraform.releases.teleport.dev/gravitational/teleport"
      version = "~> 15.0"
    }
  }
}

provider "teleport" {
  # Update addr to point to your Teleport Cloud tenant URL's host:port

  # make these and the other provider configs variables
  addr               = "${var.teleport_addr}:443"
  identity_file_path = var.identity_file_path
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
  config_context = var.kubernetes_context
}

provider "helm" {
  kubernetes {
    config_path = var.kubernetes_config_path
    config_context = var.kubernetes_context
  }
}
