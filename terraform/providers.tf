provider "digitalocean" {
    token = var.digitalocean_token
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.spm_cluster.endpoint
  token                  = digitalocean_kubernetes_cluster.spm_cluster.kube_config.0.token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.spm_cluster.kube_config.0.cluster_ca_certificate)
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}