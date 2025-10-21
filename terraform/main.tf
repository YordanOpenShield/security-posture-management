# ===============================================
# Infrastructure Module
# ===============================================

module "infrastructure" {
  source = "./modules/infrastructure"

  hetzner_token    = var.hetzner_token
  cloudflare_token = var.cloudflare_token
  tenant_name      = var.tenant
  provision_user   = var.provision_user
}

module "dns" {
  source = "./modules/dns"

  cloudflare_token = var.cloudflare_token
  tenant_name      = var.tenant
  tenant_host      = module.infrastructure.tenant_server_ip
  base_domain      = local.base_domain

  depends_on = [
    module.infrastructure
]
}