# Security Posture Management — Infra

This repository contains infrastructure and automation to provision per-tenant SPM (Security Posture Management) environments on DigitalOcean Kubernetes (DOKS). It provides Terraform to create a cluster per tenant, Kubernetes manifests for core services (OpenSearch, Dashboards, OPA, Faraday), and a GitHub Actions workflow to run provisioning on-demand.

CI-first deployment (recommended)

This project is designed to provision environments through GitHub Actions. Avoid local Terraform kubectl runs — use the workflow to ensure consistent, auditable deployments.

1. Add your DigitalOcean token to repository Secrets as `DIGITALOCEAN_TOKEN` (Settings → Secrets → Actions).

2. Trigger the workflow from the Actions UI:
   - Open the `Provision Tenant` workflow and click "Run workflow".
   - Provide `tenant` (required) and adjust other inputs as needed.

3. Or trigger via the GitHub CLI:

```bash
gh workflow run provision-tenant.yml -f tenant=demo
```

What the workflow does
- Runs `terraform apply` to create a DOKS cluster for the tenant.
- Extracts the cluster kubeconfig from Terraform output and configures kubectl on the runner.
- Renders `k8s/*.yaml` (substitutes `{{TENANT}}`) and applies the manifests.
- Performs basic rollout waits and smoke checks (port-forward + curl) to validate services.

If you need to run the pipeline programmatically or extend it, I can help add inputs/approval steps, remote state config, or secrets handling.

