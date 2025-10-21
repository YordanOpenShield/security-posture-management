variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive   = true
}

variable "provision_user" {
  description = "User to create on the server for provisioning"
  type        = string
}

variable "faraday_version" {
  description = "Version of Faraday to install"
  type        = string
  default     = "latest"
}

variable "faraday_host" {
  description = "Hostname for Faraday instance"
  type        = string
}