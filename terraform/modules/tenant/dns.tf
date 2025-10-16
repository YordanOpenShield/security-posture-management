resource "cloudflare_dns_record" "faraday" {
  zone_id = data.cloudflare_zone.openshield.zone_id
  name    = "faraday.${var.spm_subdomain}.${var.base_domain}"
  content = hcloud_server.tenant_server.ipv4_address
  type    = "A"
  ttl     = 3600

  proxied = false

  depends_on = [hcloud_server.tenant_server]
}