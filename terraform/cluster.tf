data "digitalocean_kubernetes_versions" "available" {}

resource "digitalocean_kubernetes_cluster" "spm_cluster" {
  name   = local.cluster_name
  region = var.region

  # Use user-specified version if provided; otherwise pick the first available slug
  version = var.k8s_version != "" ? var.k8s_version : data.digitalocean_kubernetes_versions.available.versions[0].slug

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
