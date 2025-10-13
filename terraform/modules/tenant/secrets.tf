resource "random_password" "pg_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "rabbitmq_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
}