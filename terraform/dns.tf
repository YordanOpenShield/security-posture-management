# Cluster DNS record
resource "cloudflare_dns_record" "spm_cluster" {
  zone_id = data.cloudflare_zone.openshield_zone.zone_id
  name    = var.cluster_domain
  content = digitalocean_kubernetes_cluster.spm_cluster.ipv4_address
  ttl     = 3600
  type    = "A"
  proxied = var.cloudflare_proxied

  depends_on = [ digitalocean_kubernetes_cluster.spm_cluster ]
}

# Tenant DNS record
resource "cloudflare_dns_record" "tenant" {
  zone_id = data.cloudflare_zone.openshield_zone.zone_id
  name    = "${var.tenant}.${var.cluster_domain}"
  content = digitalocean_kubernetes_cluster.spm_cluster.ipv4_address
  ttl     = 3600
  type    = "A"
  proxied = var.cloudflare_proxied

  depends_on = [ digitalocean_kubernetes_cluster.spm_cluster, module.tenant ]
}

# Data source to resolve the zone ID
data "cloudflare_zone" "openshield_zone" {
  filter = {
    name = var.cloudflare_zone
  }
}
