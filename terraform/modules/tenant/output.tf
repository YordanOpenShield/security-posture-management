output "host" {
    value = hcloud_server.tenant_server.ipv4_address
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "faraday_credentials" {
  value = {
    url      = "https://faraday.${var.name}.${var.spm_subdomain}.${var.base_domain}"
    username = local.faraday_user
    password = random_password.faraday_password.result
  }
  sensitive = true
}