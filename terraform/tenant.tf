module "tenant" {
  source = "./modules/tenant"

  name = var.tenant

  hetzner_token = var.hetzner_token
}

output "tenant_name" {
  value = var.tenant
}

output "tenant_host" {
  value = module.tenant.tenant_host
}

output "tenant_ssh_private_key" {
  value     = module.tenant.tenant_ssh_private_key
  sensitive = true
}

output "tenant_ssh_public_key" {
  value = module.tenant.tenant_ssh_public_key
}