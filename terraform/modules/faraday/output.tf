output "tenant_faraday_credentials" {
  value     = {
    url      = var.faraday_host
    username = local.faraday_user
    password = random_password.faraday_password.result
  }
  sensitive = true
}