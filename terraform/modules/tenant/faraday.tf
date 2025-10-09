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
      requests = {
        storage = var.postgres_storage
      }
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
    kubernetes_job.create_tables,
    kubernetes_job.initdb
  ]
}

resource "kubernetes_job" "initdb" {
  metadata {
    name      = "faraday-sql-init"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }

  spec {
    backoff_limit = 3

    template {
      metadata {
        labels = { job = "faraday-sql-init" }
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "sql-init"
          # Use the postgres image (has psql) so we don't need to install clients at runtime
          image = var.postgres_image

          command = [
            "sh",
            "-c",
            <<-EOF
            set -eux

            export PGPASSWORD="$PGSQL_PASSWD"

            # helper to wait for Postgres to accept connections
            echo "Waiting for Postgres at $PGSQL_HOST..."
            until psql -h "$PGSQL_HOST" -U "$PGSQL_USER" -d postgres -c '\q' >/dev/null 2>&1; do
              echo "Postgres unavailable - sleeping"
              sleep 2
            done

            echo "Ensuring role '$PGSQL_USER' exists and password is set"
            if psql -h "$PGSQL_HOST" -U "$PGSQL_USER" -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='$PGSQL_USER'" | grep -q 1; then
              echo "Role $PGSQL_USER exists, altering password"
              psql -h "$PGSQL_HOST" -U "$PGSQL_USER" -d postgres -c "ALTER ROLE \"$PGSQL_USER\" WITH PASSWORD '$PGSQL_PASSWD';"
            else
              echo "Creating role $PGSQL_USER"
              psql -h "$PGSQL_HOST" -U "$PGSQL_USER" -d postgres -c "CREATE ROLE \"$PGSQL_USER\" WITH LOGIN PASSWORD '$PGSQL_PASSWD';"
            fi

            echo "Ensuring database '$PGSQL_DBNAME' exists and is owned by $PGSQL_USER"
            if psql -h "$PGSQL_HOST" -U "$PGSQL_USER" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='$PGSQL_DBNAME'" | grep -q 1; then
              echo "Database $PGSQL_DBNAME already exists"
            else
              echo "Creating database $PGSQL_DBNAME"
              psql -h "$PGSQL_HOST" -U "$PGSQL_USER" -d postgres -c "CREATE DATABASE \"$PGSQL_DBNAME\" OWNER \"$PGSQL_USER\";"
            fi

            echo "SQL init complete"
            EOF
          ]

          env {
            name = "PGSQL_HOST"
            value = "${kubernetes_service.postgres.metadata[0].name}.${kubernetes_namespace.tenant_ns.metadata[0].name}.svc.cluster.local"
          }
          env {
            name = "PGSQL_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name = "PGSQL_PASSWD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "PGSQL_DBNAME"
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

resource "kubernetes_job" "create_tables" {
  metadata {
    name      = "faraday-create-tables"
    namespace = kubernetes_namespace.tenant_ns.metadata[0].name
  }

  spec {
    backoff_limit = 3

    template {
      metadata {
        labels = { job = "faraday-create-tables" }
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "create-tables"
          image = var.faraday_image
          command = ["sh", "-c", "faraday-manage create-tables"]

          env {
            name = "PGSQL_HOST"
            value = "${kubernetes_service.postgres.metadata[0].name}.${kubernetes_namespace.tenant_ns.metadata[0].name}.svc.cluster.local"
          }
          env {
            name = "PGSQL_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name = "PGSQL_PASSWD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.faraday_db_auth.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "PGSQL_DBNAME"
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

  # Ensure create-tables runs after SQL provisioning
  depends_on = [kubernetes_job.initdb]
}