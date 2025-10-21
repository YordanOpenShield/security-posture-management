variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
  type        = string
  sensitive   = true
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

variable "provision_user" {
  description = "User to create on the server for provisioning"
  type        = string
}