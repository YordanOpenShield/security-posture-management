variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
  type        = string
}

variable "tenant_name" {
  description = "Name of the tenant"
  type        = string
}

variable "server_image" {
  description = "The image to use for the server"
  type        = string
  default     = "ubuntu-22.04"
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 50
}

variable "provision_user" {
  description = "User to create on the server for provisioning"
  type        = string
}