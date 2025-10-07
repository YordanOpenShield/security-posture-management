module "tenant" {
  source = "./modules/tenant"

  # Tenant is provided via the CI workflow input (var.tenant). Region and node pool
  # settings use defaults from variables.tf so passing only the tenant is sufficient
  # for CI-first provisioning.
  tenant = var.tenant

  # images (can be overridden via root variables)
  opensearch_image = var.opensearch_image
  opa_image         = var.opa_image
  faraday_image     = var.faraday_image

  # storage
  opensearch_storage = "10Gi"

  # quota/limits (defaults from module)
}

