module "tenant" {
  source = "./modules/tenant"

  name = var.tenant
  server_location = coalesce(var.tenant_location, null)

  hetzner_token = var.hetzner_token
}