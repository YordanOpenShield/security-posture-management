module "tenant" {
  source = "./modules/tenant"

  name = var.tenant

  hetzner_token = var.hetzner_token
}