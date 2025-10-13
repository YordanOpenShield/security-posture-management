module "tenant" {
  source = "./modules/tenant"

  name = var.tenant
  server_location = var.tenant_location

  hetzner_token = var.hetzner_token
}