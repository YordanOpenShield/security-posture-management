# == Hetzner Cloud Token ==

variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
  type        = string
}

# == Cloudflare Token ==

variable "cloudflare_token" {
  description = "API token for Cloudflare"
  type        = string
}

# == Tenant Variables ==

variable "name" {
  description = "Name of the tenant"
  type        = string
}

# == Infrastructure Variables ==

variable "server_image" {
  description = "The image to use for the server"
  type        = string
  default     = "ubuntu-22.04"
}

variable "server_cpu" {
  description = "The minimum number of CPU cores for the server"
  type        = number
  default     = 2
}

variable "server_ram" {
  description = "The minimum number of GBs of RAM for the server"
  type        = number
  default     = 4
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 50
}

# == Application / provisioning variables ==

variable "provision_user" {
  description = "User to create on the server for provisioning"
  type        = string
  default     = "deploy"
}

variable "pg_user" {
  description = "Postgres user for the application database"
  type        = string
  default     = "faraday"
}

variable "pg_db" {
  description = "Postgres database name for the application"
  type        = string
  default     = "faraday"
}

variable "faraday_directory" {
  description = "Directory where the application will be installed"
  type        = string
  default     = "/opt/faraday"
}

variable "faraday_version" {
  description = "Faraday version to install or 'latest'"
  type        = string
  default     = "latest"
}

variable "faraday_password" {
  description = "Administrator password to set for Faraday"
  type        = string
  sensitive   = true
  default     = null
}

# == Domain/host variables ==

variable "spm_subdomain" {
  description = "Subdomain for the SPM instance"
  type        = string
  default     = "spm"
}

variable "base_domain" {
  description = "Domain for the Faraday instance"
  type        = string
  default     = "openshield.io"
}