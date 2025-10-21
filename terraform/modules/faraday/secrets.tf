resource "random_password" "faraday_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}