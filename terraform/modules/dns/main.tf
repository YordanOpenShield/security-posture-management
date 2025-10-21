resource "cloudflare_dns_record" "faraday" {
  zone_id = data.cloudflare_zone.openshield.zone_id
  name    = var.faraday_host
  content = var.tenant_host
  type    = "A"
  ttl     = 3600

  proxied = false
}