# Cluster DNS record
resource "cloudflare_record" "spm_cluster" {
  count = (length(var.cloudflare_zone) > 0 && length(digitalocean_kubernetes_cluster.spm_cluster.ipv4_address) > 0) ? 1 : 0

  zone_id = data.cloudflare_zones.openshield_zone.zones[0].id
  name    = var.cluster_domain
  value   = digitalocean_kubernetes_cluster.spm_cluster.ipv4_address
  ttl     = 300
  type    = "A"
  proxied = var.cloudflare_proxied

  depends_on = [ digitalocean_kubernetes_cluster.spm_cluster ]
}

# Tenant DNS record
resource "cloudflare_record" "tenant" {
  count = (length(var.cloudflare_zone) > 0 && length(digitalocean_kubernetes_cluster.spm_cluster.ipv4_address) > 0) ? 1 : 0

  zone_id = data.cloudflare_zones.openshield_zone.zones[0].id
  name    = "${var.tenant}.${var.cluster_domain}"
  value   = digitalocean_kubernetes_cluster.spm_cluster.ipv4_address
  ttl     = 300
  type    = "A"
  proxied = var.cloudflare_proxied

  depends_on = [ digitalocean_kubernetes_cluster.spm_cluster, module.tenant ]
}

# Data source to resolve the zone ID
data "cloudflare_zones" "openshield_zone" {
  filter {
    name = var.cloudflare_zone
  }
}
