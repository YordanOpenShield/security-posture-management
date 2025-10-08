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
          image = "faradaysec/faraday:latest"

          port {
            container_port = 5985
          }

          env {
            name  = "PGSQL_HOST"
            value = "postgres.faraday.svc.cluster.local"
          }
          env {
            name  = "PGSQL_USER"
            value = "faraday"
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
            value = "faraday"
          }
          env {
            name  = "CELERY_BROKER_URL"
            value = "amqp://faraday:${random_password.rabbitmq_password.result}@rabbitmq.faraday.svc.cluster.local:5672/"
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

        # Init container that waits for Postgres to be reachable on port 5432.
        # This prevents the initdb container from failing immediately when the DB is still
        # initializing or the Postgres pod is restarting.
        init_container {
          name  = "wait-for-postgres"
          image = "busybox:1.36"
          command = ["sh", "-c", "until nc -z postgres 5432; do echo waiting for postgres; sleep 2; done"]
          # small resource request so it doesn't contribute to quota pressure
          resources {
            requests = {
              cpu    = "50m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }

        container {
          name  = "initdb"
          image = "faradaysec/faraday:latest"
          command = ["faraday-manage", "initdb"]

          env {
            name  = "PGSQL_HOST"
            value = "postgres.faraday.svc.cluster.local"
          }
          env {
            name  = "PGSQL_USER"
            value = "faraday"
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
            value = "faraday"
          }
        }
      }
    }
  }
}