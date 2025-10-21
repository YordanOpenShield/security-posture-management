data "cloudflare_zone" "openshield" {
  filter = {
    name = var.base_domain
  }
}