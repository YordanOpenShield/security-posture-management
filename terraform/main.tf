# # ===============================================
# # Infrastructure Module
# # ===============================================

# module "infrastructure" {
#     source = "./modules/infrastructure"

#     hetzner_token    = var.hetzner_token
#     tenant_name      = var.tenant
#     provision_user   = local.provision_user
# }

# # ===============================================
# # DNS Module
# # ===============================================

# module "dns" {
#     source = "./modules/dns"

#     cloudflare_token = var.cloudflare_token
#     tenant_name      = var.tenant
#     tenant_host      = module.infrastructure.host
#     faraday_host     = "${local.faraday_subdomain}.${var.tenant}.${local.spm_subdomain}.${local.base_domain}"
#     base_domain      = local.base_domain
# }

# # ===============================================
# # Faraday Module
# # ===============================================

# module "faraday" {
#     source = "./modules/faraday"

#     hetzner_token     = var.hetzner_token
#     provision_user    = local.provision_user
#     provision_private_key = module.infrastructure.ssh_private_key
#     faraday_host      = module.dns.faraday_dns_record
# }