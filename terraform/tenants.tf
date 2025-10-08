module "tenant" {
  source = "./modules/tenant"

  tenant = var.tenant
  cluster_domain = var.cluster_domain
}

