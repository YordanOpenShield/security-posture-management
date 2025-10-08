resource "random_password" "postgres_password" {
  length = 20
}

resource "random_password" "rabbitmq_password" {
  length = 20
}

resource "kubernetes_secret" "faraday_db_auth" {
  metadata {
    name      = "faraday-db-secret"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  data = {
    POSTGRES_DB       = base64encode("faraday")
    POSTGRES_USER     = base64encode("faraday")
    POSTGRES_PASSWORD = base64encode(random_password.postgres_password.result)
  }
  type = "Opaque"
}

resource "kubernetes_secret" "rabbitmq_auth" {
  metadata {
    name      = "faraday-rabbitmq-secret"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  data = {
    RABBITMQ_DEFAULT_USER = base64encode("faraday")
    RABBITMQ_DEFAULT_PASS = base64encode(random_password.rabbitmq_password.result)
  }
}

resource "random_password" "opensearch_admin_pass" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "opensearch_admin_auth" {
  metadata {
    name      = "opensearch-admin-secret"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  data = {
    OPENSEARCH_PASSWORD = base64encode(random_password.opensearch_admin_pass.result)
  }
  type = "Opaque"
}