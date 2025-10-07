data "digitalocean_kubernetes_versions" "available" {}

resource "digitalocean_kubernetes_cluster" "spm_cluster" {
  name   = local.cluster_name
  region = var.region

  version = var.k8s_version != "" ? var.k8s_version : data.digitalocean_kubernetes_versions.available.latest_version

  auto_upgrade = true

  node_pool {
    name       = "spm-node-pool"
    size       = var.droplet_size
    node_count = var.min_nodes
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }

  tags = ["spm"]
}
