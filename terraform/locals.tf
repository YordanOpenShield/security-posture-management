locals {
    base_domain = "openshield.io"
    spm_subdomain = "spm.${local.base_domain}"
    faraday_subdomain = "faraday.${local.spm_subdomain}"

    provision_user = "deploy"
}