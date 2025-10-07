terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.22"
    }
  }
}

provider "digitalocean" {
    token = var.digitalocean_token
}

resource "digitalocean_kubernetes_cluster" "spm_cluster" {
  name    = local.cluster_name
  region  = var.region
  version = "1.29.4-do.2"

  auto_upgrade = true

  node_pool {
    name       = "spm-pool"
    size       = var.droplet_size
    node_count = var.min_nodes
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }

  tags = ["spm", var.tenant]
}
