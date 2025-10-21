output "tenant_name" {
  value = var.tenant
}

output "tenant_host" {
  value = module.tenant.host
}

output "tenant_ssh_private_key" {
  value     = module.tenant.ssh_private_key
  sensitive = true
}

output "tenant_ssh_public_key" {
  value = module.tenant.ssh_public_key
}

output "tenant_faraday_credentials" {
  value     = module.tenant.faraday_credentials
  sensitive = true
}