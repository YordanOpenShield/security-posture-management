module "tenant_demo" {
  source = "./modules/tenant"

  # Demo tenant for testing the CI-first provisioning and module behavior.
  # Change this to var.tenant or use for_each when creating multiple tenants.
  tenant = "demo"

  # images (can be overridden via root variables)
  opensearch_image = var.opensearch_image
  opa_image         = var.opa_image
  faraday_image     = var.faraday_image

  # storage
  opensearch_storage = "10Gi"

  # quota/limits (defaults from module)
}

