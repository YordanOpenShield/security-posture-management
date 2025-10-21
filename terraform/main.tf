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

# ===============================================
# DNS Module
# ===============================================

module "dns" {
    source = "./modules/dns"

    cloudflare_token = var.cloudflare_token
    tenant_name      = var.tenant
    tenant_host      = module.infrastructure.tenant_server_ip
    faraday_host     = "faraday.${var.tenant}.${local.spm_subdomain}.${local.base_domain}"
    base_domain      = local.base_domain

    depends_on = [
        module.infrastructure
    ]
}

# ===============================================
# Faraday Module
# ===============================================

module "faraday" {
    source = "./modules/faraday"

    hetzner_token     = var.hetzner_token
    provision_user    = local.provision_user
    faraday_host      = "faraday.${var.tenant}.${local.spm_subdomain}.${local.base_domain}"

    depends_on = [
        module.infrastructure,
        module.dns
    ]
}