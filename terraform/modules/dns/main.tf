resource "cloudflare_dns_record" "faraday" {
  zone_id = data.cloudflare_zone.openshield.zone_id
  name    = "${var.faraday_subdomain}.${var.tenant_name}.${var.spm_subdomain}.${var.base_domain}"
  content = var.tenant_host
  type    = "A"
  ttl     = 3600

  proxied = false

  depends_on = [hcloud_server.tenant_server]
}