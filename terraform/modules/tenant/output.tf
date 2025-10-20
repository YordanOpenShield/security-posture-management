output "tenant_host" {
    value = hcloud_server.tenant_server.ipv4_address
}

output "tenant_ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "tenant_ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "tenant_faraday_credentials" {
  value = {
    url      = "https://faraday.${var.name}.${var.spm_subdomain}.${var.base_domain}"
    username = "admin"
    password = random_password.faraday_admin_password.result
  }
}