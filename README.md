# Security Posture Management — Tenant Provisioning

This repository contains infrastructure and automation to provision per-tenant SPM (Security Posture Management) environments on Hetzner. It provides Terraform to create a tenant.

CI-first deployment (recommended)

This project is designed to provision environments through GitHub Actions. Avoid local Terraform kubectl runs — use the workflow to ensure consistent, auditable deployments.

1. Add your Hetzner and Cloudflare tokens to repository Secrets as `HETZNER_TOKEN` or `CLOUDFLARE_TOKEN` (Settings → Secrets → Actions).

2. Trigger the workflow from the Actions UI:
   - Open the `Provision Tenant` workflow and click "Run workflow".
   - Provide `tenant` (required) and adjust other inputs as needed.

3. Or trigger via the GitHub CLI:

```bash
gh workflow run provision-tenant.yml -f tenant=demo
```
