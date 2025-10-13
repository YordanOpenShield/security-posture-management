# == Hetzner Cloud Token ==

variable "hetzner_token" {
  description = "API token for Hetzner Cloud"
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

variable "server_location" {
  description = "The location to create the server in"
  type        = string
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 50
}