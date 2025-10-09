resource "kubernetes_service" "faraday" {
  metadata {
    name      = "faraday"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    selector = { app = "faraday" }
    port {
      port        = 5985
      target_port = 5985
    }
  }
}

resource "kubernetes_persistent_volume_claim" "faraday_storage" {
  metadata {
    name      = "faraday-storage"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "10Gi" }
    }
  }
}

resource "kubernetes_deployment" "faraday" {
  metadata {
    name      = "faraday"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "faraday" }
    }

    template {
      metadata {
        labels = { app = "faraday" }
      }

      spec {
        container {
          name  = "faraday"
          image = var.faraday_image

          port {
            container_port = 5985
          }

          env {
            name  = "PGSQL_HOST"
            value = "${kubernetes_service.postgres.metadata[0].name}.${kubernetes_namespace.tenant_ns.metadata[0].name}.svc.cluster.local"
          }
          env {
            name  = "PGSQL_USER"
            value_from {
                secret_key_ref {
                    name = kubernetes_secret.faraday_db_auth.metadata[0].name
                    key  = "POSTGRES_USER"
                }
            }
          }
          env {
            name  = "PGSQL_PASSWD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "PGSQL_DBNAME"
            value_from {
                secret_key_ref {
                    name = kubernetes_secret.faraday_db_auth.metadata[0].name
                    key  = "POSTGRES_DB"
                }
            }
          }
          env {
            name  = "CELERY_BROKER_URL"
            value = "amqp://faraday:${random_password.rabbitmq_password.result}@${kubernetes_service.rabbitmq.metadata[0].name}.${kubernetes_namespace.tenant_ns.metadata[0].name}.svc.cluster.local:5672/"
          }

          volume_mount {
            name       = "faraday-storage"
            mount_path = "/faraday-storage"
          }
        }

        volume {
          name = "faraday-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.faraday_storage.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_stateful_set.opensearch,
    kubernetes_stateful_set.postgres,
    kubernetes_job.initdb
  ]
}

resource "kubernetes_job" "initdb" {
  metadata {
    name      = "faraday-initdb"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }

  spec {
    backoff_limit = 3

    template {
      metadata {
        labels = { job = "faraday-initdb" }
      }

      spec {
        restart_policy = "OnFailure"

            container {
              name  = "initdb"
              image = var.faraday_image
              # Run as root so package installation (apk/apt-get) can succeed when
              # we attempt to install sudo at runtime. This wrapper tries apk then
              # apt-get and falls back if neither is present.
              security_context {
                run_as_user = 0
              }
              command = ["faraday-manage", "create-tables"]

          env {
            name  = "PGSQL_HOST"
            value = "${kubernetes_service.postgres.metadata[0].name}.${kubernetes_namespace.tenant_ns.metadata[0].name}.svc.cluster.local"
          }
          env {
            name  = "PGSQL_USER"
            value_from {
                secret_key_ref {
                    name = kubernetes_secret.faraday_db_auth.metadata[0].name
                    key  = "POSTGRES_USER"
                }
            }
          }
          env {
            name  = "PGSQL_PASSWD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name  = "PGSQL_DBNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
        }
      }
    }
  }
}