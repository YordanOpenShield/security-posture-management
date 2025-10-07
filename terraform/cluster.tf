resource "digitalocean_kubernetes_cluster" "spm_cluster" {
  name    = local.cluster_name
  region  = var.region
  version = "latest"

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
