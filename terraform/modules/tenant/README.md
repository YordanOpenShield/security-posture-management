# Terraform module: tenant

Purpose

This Terraform module provisions per-tenant Kubernetes resources in an existing cluster using the Kubernetes provider. It is intentionally lightweight and focused on tenant isolation and resource constraints. The module creates:

- Namespace for the tenant
- ResourceQuota (to set max resources across the namespace)
- LimitRange (to provide default/min/max pod/container limits)
- PersistentVolumeClaim (for OpenSearch storage)
- Deployments for OpenSearch, Faraday, and OPA (basic manifests)
- Services for the above workloads

This module is optimized for CI-first workflows where the cluster and provider are created outside (or in a parent Terraform module) and the Kubernetes provider is configured in the root module.

Module contract (inputs / outputs / behavior)

Inputs

- tenant (string, required) — unique tenant name used for namespace and resource names.
- opensearch_image (string, required) — container image for OpenSearch.
- faraday_image (string, required) — container image for Faraday.
- opa_image (string, required) — container image for OPA.
- opensearch_storage (string, optional, default: "10Gi") — PVC size for OpenSearch data.
- resource_quota (map, optional) — keys: cpu, memory, pods, persistentvolumeclaims, configmaps, secrets. Values should be strings like "4", "8Gi" etc. Example: { cpu = "4", memory = "8Gi", pods = "50" }
- limit_range (map, optional) — container-level request/limit defaults. Example shape:
  {
    default = { cpu = "250m", memory = "512Mi" }
    default_request = { cpu = "100m", memory = "256Mi" }
    max = { cpu = "2", memory = "2Gi" }
    min = { cpu = "50m", memory = "64Mi" }
  }
- resources_map (map, optional) — per-deployment resource requests/limits. Example:
  {
    opensearch = { requests = { cpu = "500m", memory = "1Gi" }, limits = { cpu = "1", memory = "2Gi" } }
    faraday = { requests = { cpu = "250m", memory = "256Mi" }, limits = { cpu = "500m", memory = "512Mi" } }
    opa = { requests = { cpu = "50m", memory = "64Mi" }, limits = { cpu = "100m", memory = "128Mi" } }
  }

Notes on inputs:
- The module does not manage secrets. If credentials are required for services, use external secrets, sealed secrets, or the Kubernetes Secret resource from a secure pipeline.
- The Kubernetes provider must be configured at the root with appropriate credentials (kubeconfig or host/token/cluster_ca_certificate).

Outputs

- namespace_name (string) — name of the created namespace.
- opensearch_service_name (string) — Service name for OpenSearch.
- faraday_service_name (string) — Service name for Faraday.
- opa_service_name (string) — Service name for OPA.
- opensearch_pvc_name (string) — name of the created PVC.

Example: single tenant usage

```hcl
module "tenant_a" {
  source = "../../modules/tenant"

  tenant           = "tenant-a"
  opensearch_image = var.opensearch_image
  faraday_image    = var.faraday_image
  opa_image        = var.opa_image

  opensearch_storage = "20Gi"

  resource_quota = {
    cpu                       = "8"
    memory                    = "16Gi"
    pods                      = "100"
    persistentvolumeclaims    = "2"
  }

  limit_range = {
    default = { cpu = "500m", memory = "512Mi" }
    default_request = { cpu = "250m", memory = "256Mi" }
    max = { cpu = "4", memory = "8Gi" }
    min = { cpu = "50m", memory = "64Mi" }
  }

  resources_map = {
    opensearch = { requests = { cpu = "500m", memory = "1Gi" }, limits = { cpu = "1", memory = "2Gi" } }
    faraday    = { requests = { cpu = "250m", memory = "256Mi" }, limits = { cpu = "500m", memory = "512Mi" } }
    opa        = { requests = { cpu = "50m", memory = "64Mi" }, limits = { cpu = "100m", memory = "128Mi" } }
  }
}
```

Example: creating many tenants (for_each)

```hcl
variable "tenants" {
  type = map(object({
    opensearch_storage = string
  }))
  default = {
    tenant-a = { opensearch_storage = "20Gi" }
    tenant-b = { opensearch_storage = "10Gi" }
  }
}

module "tenants" {
  source = "../../modules/tenant"
  for_each = var.tenants

  tenant           = each.key
  opensearch_image = var.opensearch_image
  faraday_image    = var.faraday_image
  opa_image        = var.opa_image
  opensearch_storage = each.value.opensearch_storage

  # reuse other variables as needed
}
```

How this differs from using Helm

- Current approach: the module creates Kubernetes resources directly (Namespace, Deployments, Services, PVC, etc.) via the Kubernetes Terraform provider. This gives explicit, version-controlled resource manifests baked into Terraform state and plan outputs.

- Helm approach: using the Helm provider (or `helm_release`) would delegate packaging and lifecycle to chart templates. Advantages:
  - Easier upgrades using chart versioning and configurable values.yaml
  - More feature-rich charts for OpenSearch (plugins, JVM tuning, cluster topology)
  - Many community charts already implement StatefulSets, persistent storage patterns, and probes

- Tradeoffs:
  - Helm introduces a separate lifecycle and release object that Terraform will manage (different crash/upgrade semantics).
  - Charts can be more complex to control from Terraform variables unless you maintain values files.

Because you requested "no Helm for now", this module intentionally keeps resources simple and easy to review in Terraform plans. When you decide to migrate, the module can be replaced with a wrapper that calls a `helm_release` and converts the module inputs into values.yaml.

Security and operational recommendations

- Use a remote state backend (Terraform Cloud, S3/Spaces + Dynamo-like lock, or other supported backend) for team collaboration and to avoid committing state to git.
- Do NOT store sensitive data (passwords, tokens, TLS keys) in plaintext Terraform variables. Use secrets management (Vault, external secrets) and Kubernetes Secrets that are created in CI from secure stores.
- Consider adding RBAC Roles/RoleBindings per namespace for tenant-level service accounts if you need stricter separation.
- Consider NetworkPolicies to limit cross-namespace network access between tenants.

Testing and verification

From the repo root or the Terraform root where the Kubernetes provider is configured:

```powershell
terraform init
terraform plan -var-file=ci.tfvars
terraform apply -var-file=ci.tfvars

# then verify in cluster
kubectl get ns
kubectl -n tenant-a get all
```

Edge cases and known limitations

- This module provides a basic OpenSearch deployment and is not production hardened: for production you may want an operator or official OpenSearch Helm chart with StatefulSets, master/data/ingest separation, replica tuning, and proper persistent storage class configuration.
- PVC class is not forced here; ensure your cluster has an appropriate default StorageClass or pass a storage_class_name variable if you need to pin it.
- Secrets (e.g., OpenSearch passwords) are not created inside the module. The module intentionally avoids embedding credentials.

Next steps and suggestions

- Add an optional `storage_class_name` variable to pin PVC class.
- Add RBAC Role/RoleBinding and optionally a ServiceAccount per tenant to scope access.
- Add NetworkPolicy defaults to restrict ingress/egress between tenant namespaces.
- Replace the OpenSearch Deployment with a StatefulSet or consider using the official OpenSearch Helm chart when you want production-grade clusters.

License

This README and module are provided as-is. There is no license file in the module — copy or adapt as needed for your project.
