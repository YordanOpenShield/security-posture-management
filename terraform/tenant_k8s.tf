module "tenant" {
  source = "./modules/tenant"

  tenant = var.tenant

  # images (can be overridden via root variables)
  opensearch_image = var.opensearch_image
  opa_image         = var.opa_image
  faraday_image     = var.faraday_image

  # storage
  opensearch_storage = "10Gi"

  # quota/limits (defaults from module)
}
